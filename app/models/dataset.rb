require "datastreams/workflow_rdf_datastream"
require "datastreams/dataset_rdf_datastream"
require "datastreams/relations_rdf_datastream"
require "datastreams/dataset_admin_rdf_datastream"
require "dataset_agreement"
#require "person"
require "rdf"
require 'uri'
require "fileutils"

class Dataset < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Sufia::GenericFile::AccessibleAttributes
  #include Sufia::GenericFile::WebForm
  include Sufia::Noid
  include Hydra::ModelMethods
  include DoiMethods
  include ContentMethods

  attr_accessible *(DatasetRdfDatastream.fields + RelationsRdfDatastream.fields + [:permissions, :permissions_attributes, :workflows, :workflows_attributes] + DatasetAdminRdfDatastream.fields)
  
  before_create :initialize_submission_workflow

  before_save :remove_blank_assertions

  has_metadata :name => "descMetadata", :type => DatasetRdfDatastream
  has_metadata :name => "workflowMetadata", :type => WorkflowRdfDatastream
  has_metadata :name => "relationsMetadata", :type => RelationsRdfDatastream
  has_metadata :name => "adminMetadata", :type => DatasetAdminRdfDatastream

  belongs_to :hasRelatedAgreement, :property=>:has_agreement, :class_name=>"DatasetAgreement"

  has_attributes :workflows, :workflows_attributes, datastream: :workflowMetadata, multiple: true
  has_attributes *DatasetRdfDatastream.fields, datastream: :descMetadata, multiple: true
  has_attributes *RelationsRdfDatastream.fields, datastream: :relationsMetadata, multiple: true
  has_attributes *DatasetAdminRdfDatastream.fields, datastream: :adminMetadata, multiple: true

  #has_and_belongs_to_many :authors, :property=> :has_author, :class_name=>"Person"
  #has_and_belongs_to_many :contributors, :property=> :has_contributor, :class_name=>"Person"

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    solr_doc[Solrizer.solr_name('label')] = self.label
    return solr_doc
  end

  def apply_permissions(depositor)
    prop_ds = self.datastreams["workflowMetadata"]
    rights_ds = self.datastreams["rightsMetadata"]
    depositor_id = depositor.respond_to?(:user_key) ? depositor.user_key : depositor
    if prop_ds
      prop_ds.depositor = depositor_id unless prop_ds.nil?
    end
    rights_ds.permissions({:person=>depositor_id}, 'edit') unless rights_ds.nil?
    rights_ds.permissions({:group=>"reviewer"}, 'edit') unless rights_ds.nil?
    return true
  end
  
  def to_jq_upload(title, size, pid, dsid)
    return {
      "name" => title, #self.title,
      "size" => size, #self.file_size,
      "url" => "/datasets/#{pid}/file/#{dsid}", #"/dataset/#{noid}",
      "thumbnail_url" => thumbnail_url(title, '48'),#self.pid,
      "delete_url" => "/datasets/#{pid}/file/#{dsid}", #"/dataset/#{noid}",
      "delete_type" => "DELETE"
    }
  end

  def datastream_opts(dsid)
    opts = {}
    #move to model??
    #TODO: Check that its label is attributes.json and mime type is application/json and need to resque from parse
    if self.datastreams.keys.include?(dsid) && dsid.start_with?("content")
      opts = self.datastreams[dsid].content
      begin
        opts = JSON.parse(opts)
      rescue
        opts = {}
      end
    end
    opts
  end

  def mint_datastream_id
    dsid = "content%s"% Sufia::Noid.noidify(Sufia::IdService.mint)
    dsid
  end

  def file_location(dsid)
    opts = self.datastream_opts(dsid)
    location = opts.fetch('dsLocation', nil)
    dsid_location = nil
    if location.is_a?(String)
      if location.include?(data_dir)
        dsid_location = location
      elsif location =~ /\A#{URI::regexp}\z/
        dsid_location = location
      end
    elsif location.is_a?(Hash) && ['silo', 'dataset', 'filename'].all? {|k| location.key? k}
      filename = File.basename(location['filename'])
      @databank = Databank.new(Sufia.config.databank_credentials['host'], username=Sufia.config.databank_credentials['username'], password=Sufia.config.databank_credentials['password'])
      dsid_location = @databank.getUrl(location['silo'], dataset=location['dataset'], filename=location['filename'])
    end
    dsid_location
  end

  def is_url?(location)
    if location =~ URI::regexp(['http', 'https'])
      return true
    else
      return false
    end
  end

  def is_on_disk?(location)
    location.include?(data_dir) && File.exist?(location)    
  end

  def add_content(file, filename)
    location = save_file_to_disk(file, filename)
    dsid = save_file_associated_datastream(filename, location, file.size)
    save_file_metadata(location, file.size)
    return dsid
  end

  def delete_content(dsid)
    location = self.file_location(dsid)
    opts = self.datastream_opts(dsid)
    #TODO: Delete file in Databank and ORA, if location is url
    if self.is_on_disk?(location)
      delete_file(location)
      self.datastreams[dsid].delete
      parts = self.hasPart
      self.hasPart = nil
      self.hasPart = parts.select { |key| not key.id.to_s.include? dsid }
      self.adminDigitalSize = Integer(self.adminDigitalSize.first) - Integer(opts['size']) rescue self.adminDigitalSize
    end
  end

  def delete_local_copy(dsid, local_path)
    # Check the datastream associated to the file has remote location of file
    location = self.file_location(dsid)
    unless self.is_url?(location)
      return false
    end
    # Check the remote location (url) is correct
    begin
      timeout(5) { @stream = open(location, :http_basic_authentication=>[Sufia.config.databank_credentials['username'], Sufia.config.databank_credentials['password']]) }
    rescue
      return false
    end
    if @stream.status[0].to_i < 200 || @stream.status[0].to_i > 299 
      return false
    end
    # Delete file
    delete_file(local_path)
  end

  def delete_dir(force=false)
    unless force
      FileUtils.rmdir(data_dir) if Dir.exist?(data_dir) && Dir["#{data_dir}/*"].empty?
    else
      FileUtils.rm_rf(data_dir) if Dir.exist?(data_dir)
    end
  end

  def create_external_datastream(dsid, url, file_name, file_size)
    set_title_and_label(file_name, :only_if_blank=>true )
    mime_types = MIME::Types.of(file_name)
    mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
    attrs = {:dsLabel => dsid, :controlGroup => "E", :dsLocation=>url, :mimeType=>mime_type, :dsid=>dsid, :size=>file_size}
    ds = create_datastream(ActiveFedora::Datastream, dsid, attrs)
    ds
  end

  def model_klass
    self.class.model_name.to_s
  end

  def update_datastream_location(dsid, location)
    opts = self.datastream_opts(dsid)
    opts["dsLocation"] = location
    self.datastreams[dsid].content = opts.to_json
  end

  private
  
  def initialize_submission_workflow
    if self.workflows.empty?  
      wf = self.workflows.build(identifier:"MediatedSubmission")
      wf.entries.build(status:Sufia.config.draft_status, date:Time.now.to_s)
    end
  end

  def remove_blank_assertions
    DatasetRdfDatastream.fields.each do |key|
      if !["temporal", "dateCollected", "spatial"].include?(key)
        self[key] = nil if self[key] == ['']
      end
    end
  end

  def self.find_or_create(pid)
    begin
      Dataset.find(pid)
    rescue ActiveFedora::ObjectNotFoundError
      Dataset.create({pid: pid})
    end
  end

  def data_dir
    File.join(Sufia.config.data_root_dir, self.id)
  end

  def save_file_to_disk(file, filename)
    FileUtils::mkdir_p(data_dir)
    # create the file path
    path = File.join(data_dir, filename)
    #If the file exists, append a count to the filename
    extn = File.extname(path)
    fn = File.basename(path, extn)
    dirname = File.dirname(path)
    count = 0
    while File.file?(path)
      count += 1
      fnNew = "#{fn}-#{count}"
      path = File.join(dirname,"#{fnNew}#{extn}")
    end
    # write the file
    File.open(path, "wb") { |f| f.write(file.read) }
    path
  end

  def save_file_associated_datastream(filename, location, file_size)
    # Prepare data for associated datastream
    dsid = self.mint_datastream_id()
    mime_types = MIME::Types.of(filename)
    mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
    opts = {:dsLabel => filename, :controlGroup => "E", :dsLocation=>location, :mimeType=>mime_type, :dsid=>dsid, :size=>file_size}

    # Add the datastream associated to the file
    dsfile = StringIO.new(opts.to_json)
    self.add_file(dsfile, dsid, "attributes.json")
    dsid
  end

  def save_file_metadata(location, file_size)
    # Add the file location to the admin metadata
    if !self.adminLocator.include?(File.dirname(location))
      self.adminLocator << File.dirname(location)
    end
    size = Integer(self.adminDigitalSize.first) rescue 0
    self.adminDigitalSize = size + file_size
    self.medium = Sufia.config.data_medium["Digital"]
  end

  def delete_file(filepath)
    File.delete(filepath) if File.exist?(filepath)
  end

end

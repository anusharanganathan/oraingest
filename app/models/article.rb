# app/models/journal_article.rb
# a Fedora object for the Article hydra content type
class Article < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hydra::Datastream
  
  has_metadata :name => "descMetadata", :type=> ArticleModsDatastream
  has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata

  # The delegate method allows you to set up attributes on the model that are stored in datastreams
  # When you set :unique=>"true", searches will return a single value instead of an array.
  delegate :pid, :to=>"descMetadata", :unique=>"true"
  delegate :urn, :to=>"descMetadata", :unique=>"true"

  delegate :title, :to=>"descMetadata", :unique=>"true"
  delegate :subtitle, :to=>"descMetadata", :unique=>"true"

  delegate :abstract, :to=>"descMetadata", :unique=>"true"

  delegate :journal_title, :to=>"descMetadata", :unique=>"true"
  delegate :journal_volume, :to=>"descMetadata", :unique=>"true"
  delegate :journal_issue, :to=>"descMetadata", :unique=>"true"
  delegate :start_page, :to=>"descMetadata", :unique=>"true"
  delegate :end_page, :to=>"descMetadata", :unique=>"true"
  delegate :page_numbers, :to=>"descMetadata", :unique=>"true"

  delegate :agent, :to=>"descMetadata"
  delegate :person, :to=>"descMetadata"
  delegate :organisation, :to=>"descMetadata"
  delegate :copyright_holder, :to=>"descMetadata"
  
  delegate :type, :to=>"descMetadata"
  delegate :subtype, :to=>"descMetadata"

  delegate :publication_date, :to=>"descMetadata", :unique=>"true"
  delegate :creation_date, :to=>"descMetadata", :unique=>"true"
  delegate :copyright_date, :to=>"descMetadata", :unique=>"true"

  delegate :language, :to=>"descMetadata"
  delegate :physical_description, :to=>"descMetadata"
  delegate :subject, :to=>"descMetadata"
  delegate :keyword, :to=>"descMetadata"
  delegate :license, :to=>"descMetadata", :unique=>"true"

  delegate :identifier, :to=>"descMetadata"
  delegate :local_id, :to=>"descMetadata"
  delegate :doi, :to=>"descMetadata", :unique=>"true"
  delegate :issn, :to=>"descMetadata", :unique=>"true"
  delegate :eissn, :to=>"descMetadata", :unique=>"true"
  delegate :publisher_id, :to=>"descMetadata", :unique=>"true"
  delegate :barcode, :to=>"descMetadata", :unique=>"true"
  delegate :pii, :to=>"descMetadata", :unique=>"true"
  delegate :article_number, :to=>"descMetadata", :unique=>"true"

  delegate :note, :to=>"descMetadata", :unique=>"true"
  delegate :publisher_note, :to=>"descMetadata", :unique=>"true"
  delegate :admin_note, :to=>"descMetadata", :unique=>"true"

  delegate :related_item, :to=>"descMetadata"

=begin
  def attributes=(properties)
    if (properties["person"])
      self.descMetadata.agent.nodeset.remove  # wipe out existing values
      count = 0
      properties["person"].each_with_index do |subject_hash, index|
        self.descMetadata.person(count).first_name = subject_hash["first_name"]
        self.descMetadata.person(count).last_name = subject_hash["last_name"]
        self.descMetadata.person(count).display_name = subject_hash["display_name"]
        self.descMetadata.person(count).term_of_address = subject_hash["term_of_address"]
        self.descMetadata.person(count).role = subject_hash["role"]
        self.descMetadata.person(count).webauth = subject_hash["webauth"]
        self.descMetadata.person(count).pid = subject_hash["pid"]
        self.descMetadata.person(count).institution = subject_hash["institution"]
        self.descMetadata.person(count).faculty = subject_hash["faculty"]
        self.descMetadata.person(count).research_group = subject_hash["research_group"]
        self.descMetadata.person(count).oxford_college = subject_hash["oxford_college"]
        self.descMetadata.person(count).affiliation = subject_hash["affiliation"]
        self.descMetadata.person(count).funder = subject_hash["funder"]
        self.descMetadata.person(count).grant_number = subject_hash["grant_number"]
        self.descMetadata.person(count).website = subject_hash["website"]
        self.descMetadata.person(count).email = subject_hash["email"]
        self.descMetadata.person(count).rights_ownership = subject_hash["rights_ownership"]
        self.descMetadata.person(count).third_party_copyright = subject_hash["third_party_copyright"]
        count = count + 1 
      end
      properties.delete("person")
    end
    if (properties["organisation"])
      self.descMetadata.agent.nodeset.remove  # wipe out existing values
      count = 0
      properties["organisation"].each_with_index do |subject_hash, index|
        self.descMetadata.organisation(count).first_name = subject_hash["first_name"]
        self.descMetadata.organisation(count).last_name = subject_hash["last_name"]
        self.descMetadata.organisation(count).display_name = subject_hash["display_name"]
        self.descMetadata.organisation(count).term_of_address = subject_hash["term_of_address"]
        self.descMetadata.organisation(count).role = subject_hash["role"]
        self.descMetadata.organisation(count).webauth = subject_hash["webauth"]
        self.descMetadata.organisation(count).pid = subject_hash["pid"]
        self.descMetadata.organisation(count).institution = subject_hash["institution"]
        self.descMetadata.organisation(count).faculty = subject_hash["faculty"]
        self.descMetadata.organisation(count).research_group = subject_hash["research_group"]
        self.descMetadata.organisation(count).oxford_college = subject_hash["oxford_college"]
        self.descMetadata.organisation(count).affiliation = subject_hash["affiliation"]
        self.descMetadata.organisation(count).funder = subject_hash["funder"]
        self.descMetadata.organisation(count).grant_number = subject_hash["grant_number"]
        self.descMetadata.organisation(count).website = subject_hash["website"]
        self.descMetadata.organisation(count).email = subject_hash["email"]
        self.descMetadata.organisation(count).rights_ownership = subject_hash["rights_ownership"]
        self.descMetadata.organisation(count).third_party_copyright = subject_hash["third_party_copyright"]
        count = count + 1 
      end
      properties.delete("organisation")
    end
    if (properties["agent"])
      puts "I am in properties"
      self.descMetadata.agent.nodeset.remove  # wipe out existing values
      count = 0
      properties["agent"].each_with_index do |subject_hash, index|
        self.descMetadata.agent(count).first_name = subject_hash["first_name"]
        self.descMetadata.agent(count).last_name = subject_hash["last_name"]
        self.descMetadata.agent(count).display_name = subject_hash["display_name"]
        self.descMetadata.agent(count).term_of_address = subject_hash["term_of_address"]
        self.descMetadata.agent(count).role = subject_hash["role"]
        self.descMetadata.agent(count).webauth = subject_hash["webauth"]
        self.descMetadata.agent(count).pid = subject_hash["pid"]
        self.descMetadata.agent(count).institution = subject_hash["institution"]
        self.descMetadata.agent(count).faculty = subject_hash["faculty"]
        self.descMetadata.agent(count).research_group = subject_hash["research_group"]
        self.descMetadata.agent(count).oxford_college = subject_hash["oxford_college"]
        self.descMetadata.agent(count).affiliation = subject_hash["affiliation"]
        self.descMetadata.agent(count).funder = subject_hash["funder"]
        self.descMetadata.agent(count).grant_number = subject_hash["grant_number"]
        self.descMetadata.agent(count).website = subject_hash["website"]
        self.descMetadata.agent(count).email = subject_hash["email"]
        self.descMetadata.agent(count).rights_ownership = subject_hash["rights_ownership"]
        self.descMetadata.agent(count).third_party_copyright = subject_hash["third_party_copyright"]
        count = count + 1 
      end
      properties.delete("agent")
    end
    if (properties["related_item"])
      self.descMetadata.related_item.nodeset.remove  # wipe out existing values
      count = 0
      properties["related_item"].each_with_index do |subject_hash, index|
        self.descMetadata.related_item(count).type = subject_hash["type"]
        self.descMetadata.related_item(count).title = subject_hash["title"]
        self.descMetadata.related_item(count).location = subject_hash["location"]
        self.descMetadata.related_item(count).name = subject_hash["name"]
        count = count + 1 
      end
      properties.delete("related_item")
    end
    super
 end
=end
end

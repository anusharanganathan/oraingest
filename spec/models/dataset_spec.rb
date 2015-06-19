require 'rails_helper'

describe Dataset do
  it_behaves_like 'doi_methods'

  describe 'attributes' do

    before do
      @dataset = Dataset.new
    end

    subject { @dataset }

    it { is_expected.to respond_to(:permissions) }
    # it { is_expected.to respond_to(:permissions_attributes) }
    it { is_expected.to respond_to(:workflows) }
    # it { is_expected.to respond_to(:workflows_attributes) }
    context 'DatasetRdfDatastream' do
      it { is_expected.to respond_to(:title) }
      it { is_expected.to respond_to(:subtitle) }
      it { is_expected.to respond_to(:abstract) }
      it { is_expected.to respond_to(:subject) }
      it { is_expected.to respond_to(:keyword) }
      it { is_expected.to respond_to(:worktype) }
      it { is_expected.to respond_to(:language) }
      it { is_expected.to respond_to(:license) }
      it { is_expected.to respond_to(:dateCopyrighted) }
      it { is_expected.to respond_to(:rightsHolder) }
      it { is_expected.to respond_to(:rights) }
      it { is_expected.to respond_to(:rightsActivity) }
      it { is_expected.to respond_to(:creation) }
      it { is_expected.to respond_to(:funding) }
      it { is_expected.to respond_to(:publication) }
    end

    context 'RelationsRdfDatastream' do
      it { is_expected.to respond_to(:hasPart) }
      it { is_expected.to respond_to(:accessRights) }
      it { is_expected.to respond_to(:influence) }
      it { is_expected.to respond_to(:qualifiedRelation) }
    end

    context 'DatasetAdminRdfDatastream' do
      it { is_expected.to respond_to(:hasAgreement) }
      it { is_expected.to respond_to(:storageAgreement) }
      it { is_expected.to respond_to(:note) }
      it { is_expected.to respond_to(:adminLocator) }
      it { is_expected.to respond_to(:adminDigitalSize) }
    end

  end

  describe 'when creating a new dataset' do
    before do
      @dataset = Dataset.new
    end

    after do
      @dataset.delete
    end

    it 'initializes the submission workflow' do
      @dataset.save
      expect(@dataset.workflows).not_to be_empty
      wf = @dataset.workflows.select{|wf| wf.identifier.first =="MediatedSubmission"}.first
      expect(wf.current_status).to eq ("Draft")
    end

    it 'removes blank assertions' do
      @dataset.title = 'Test title'
      @dataset.subtitle = ''
      @dataset.save
      expect(@dataset.title).to eq(['Test title'])
      expect(@dataset.subtitle).to eq([])
      expect(@dataset.keyword).to eq([])
    end
  end

  describe 'applying permissions' do
    before do
      @dataset = Dataset.new
      @reviewer = FactoryGirl.find_or_create(:reviewer)
      @dataset.apply_permissions(@reviewer)
    end

    it 'should set the permisions' do
      expect(@dataset.permissions).not_to be_empty
    end

    it 'sets the permissions to reviewer/group/edit' do
      permission = @dataset.permissions.first
      expect(permission.name).to eq('reviewer')
      expect(permission.type).to eq('group')
      expect(permission.access).to eq('edit')
    end
  end

  describe '#to_jq_upload' do
    before do
      @dataset = Dataset.new
      @jq_upload = @dataset.to_jq_upload('title', 120, 'uuid:nn999n999', 'dsid')
    end

    it 'creates the jq upload params' do
      expect(@jq_upload).to be_a(Hash)
    end

    it 'sets the name' do
      expect(@jq_upload['name']).to eq('title')
    end

    it 'sets the size' do
      expect(@jq_upload['size']).to eq(120)
    end

    it 'sets the url' do
      expect(@jq_upload['url']).to eq('/datasets/uuid:nn999n999/file/dsid')
    end

    it 'sets the thumbnail url' do
      expect(@jq_upload['thumbnail_url']).to eq('fileIcons/default-icon-48x48.png')
    end

    it 'sets the delete url' do
      expect(@jq_upload['delete_url']).to eq('/datasets/uuid:nn999n999/file/dsid')
    end

    it 'sets the delete type' do
      expect(@jq_upload['delete_type']).to eq('DELETE')
    end

  end

  describe 'mint datastream id' do
    before do
      @dataset = Dataset.new
      @dsid = @dataset.mint_datastream_id
    end

    it 'creates the datastream identifier' do
      expect(@dsid).not_to be_empty
      expect(@dsid).to be_a(String)
    end

  end

  describe 'get the class name' do
    before do
      @dataset = Dataset.new
    end

    it 'returns the class name' do
      expect(@dataset.model_klass).to eq('Dataset')
    end

  end

  describe 'test if url' do
    before do
      @dataset = Dataset.new
      @url1 = 'https://databank.ora.ox.ac.uk/sandbox/datasets/1935724d-48d4-40d3-b407-22dda3d3d352/EEBO-TCP Phase 1 XML Files TEI P3 (2001).zip'
      @url2 = 'http://10.0.0.173/sandbox/datasets/d46cb6d7-abbf-4057-9bde-22eba7812434/master.log'
      @url3 = 'ftp://jkorpela@alfa.hut.fi/m/fs/lai/lai/LK/lk/jkorpela/.plan'
    end

    it 'returns the class name' do
      expect(@dataset.is_url?(@url1)).to be true
      expect(@dataset.is_url?(@url2)).to be true
      expect(@dataset.is_url?(@url3)).to be false
    end

  end

  describe 'Add a file' do
    it "is implemented but rspec add file not working" do
    skip "is skipped" do

    before do
      @dataset = Dataset.new
      @file = StringIO.new
      @file.write("Hello world!")
      @dsid = @dataset.add_content(@file, 'test.txt')
      @dataset.save!
    end

    after do
      @dataset.delete
      File.delete('/tmp/test.txt')
    end

    it 'returns a datastream id' do
      expect(@dsid).not_to be_empty
      expect(@dsid).to be_a(String)
    end

    it 'saves the datastream' do
      expect(@dataset.datastreams.keys).to include(@dsid)
    end

    it 'returns the datastream options' do
      expected_keys = ['dsLabel', 'dsLocation', 'mimeType', 'dsid', 'size']
      opts = @dataset.datastream_opts(@dsid)
      expect(opts).to be_a(Hash)
      expect(opts).to include(expected_keys)
      expect(opts['dsLocation']).to be_a(String)
      expect(opts['dsLocation']).to include('test.txt')
      expect(opts['dsLocation']).to include(@dataset.id)
    end

    it 'returns the file location' do
      loc = @dataset.file_location(@dsid)
      expect(loc).not_to be_empty
      expect(loc).to include('test.txt')
      expect(loc).to include(@dataset.id)
    end

    it 'adds the file size to admin metadata' do
      expect(@dataset.adminDigitalSize).not_to be_empty
      expect(@dataset.adminDigitalSize.first).to eq(@file.size)
    end

    it 'adds the file location to admin metadata' do
      expect(@dataset.adminLocator).not_to be_empty
      loc = @dataset.file_location(@dsid)
      expect(@dataset.adminLocator).to include(loc)
    end

    it 'sets the medium to fabio:DigitalStorageMedium' do
      expect(@dataset.medium).not_to be_empty
      expect(@dataset.medium).to include('http://purl.org/spar/fabio/DigitalStorageMedium')
    end

    it 'file is saved on disk' do
      loc = @dataset.file_location(@dsid)
      expect(@dataset.is_on_disk?(loc)).to be true
    end

    it 'is not a url' do
      loc = @dataset.file_location(@dsid)
      expect(@dataset.is_url?(loc)).to be false
    end

    end
    end
  end

  describe 'update datastream location' do
    it "is implemented but rspec add file not working" do
    skip "is skipped" do

    before do
      @dataset = Dataset.new
      @file = StringIO.new
      @file.write("Hello world!")
      @dsid = @dataset.add_content(@file, 'test.txt')
      dataset_id = @dataset.id.gsub('uuid:', '')
      @new_loc = {
        'silo' => 'sandbox',
        'dataset' => dataset_id,
        'filename' => 'test.txt',
        'url' => "http://10.0.0.173/sandbox/datasets/#{dataset_id}/test.txt" }
      @dataset.update_datastream_location(@dsid, @new_loc)
      @dataset.save!
    end

    after do
      @dataset.delete
      File.delete('/tmp/test.txt')
    end

    it 'updates the datastream location' do
      expected_keys = ['dsLabel', 'dsLocation', 'mimeType', 'dsid', 'size']
      opts = @dataset.datastream_opts(@dsid)
      expect(opts).to be_a(Hash)
      expect(opts).to include(expected_keys)
      expect(opts['dsLocation']).to be_a(Hash)
      expect(opts['dsLocation']).to eq(@new_loc)
    end

    it 'returns the file location' do
      loc = @dataset.file_location(@dsid)
      expect(loc).not_to be_empty
      expect(loc).to eq(@new_loc['url'])
    end

    it 'is a url' do
      loc = @dataset.file_location(@dsid)
      expect(@dataset.is_url?(loc)).to be true
    end

    end
    end
  end

  describe 'delete content' do
    it "is implemented but rspec add file not working" do
    skip "is skipped" do

    before do
      @dataset = Dataset.new
      @file = StringIO.new
      @file.write("Hello world!")
      @dsid = @dataset.add_content(@file, 'test.txt')
      dataset_id = @dataset.id.gsub('uuid:', '')
      @location = @dataset.file_location(@dsid)
      @dataset.delete_content(@dsid)
      @dataset.save!
    end

    after do
      @dataset.delete
      File.delete('/tmp/test.txt')
    end

    it 'deletes the datastream do' do
      expect(@dataset.datastreams.keys).not_to include(@dsid)
      @opts = @dataset.datastream_opts(@dsid)
      expect(@opts).to be_a(Hash)
      expect(@opts).to be_empty
    end

    it 'removes the file size from admin metadata' do
      expect(@dataset.adminDigitalSize).not_to be_empty
      expect(@dataset.adminDigitalSize.first).to eq(0)
    end

    it 'removes the file location from admin metadata' do
      expect(@dataset.adminLocator).not_to include(@location)
    end

    it 'is not on disk' do
      expect(@dataset.is_on_disk?(@location)).to be false
    end

    it 'does not have related metadata' do
      parts = @dataset.hasPart.select { |key| key.id.to_s.include? @dsid }
      expect(hasPart).to be_empty
    end

    end
    end
  end

  describe 'delete file locally if url' do
    it "is implemented but rspec add file not working" do
    skip "is skipped" do

    before do
      @dataset = Dataset.new
      @file = StringIO.new
      @file.write("Hello world!")
      @dsid = @dataset.add_content(@file, 'test.txt')
      @location = @dataset.file_location(@dsid)
      dataset_id = @dataset.id.gsub('uuid:', '')
      @dataset.save!
    end

    after do
      @dataset.delete
      File.delete('/tmp/test.txt')
    end

    it 'does not delete the file locally if location is not url' do
      ans = @dataset.delete_local_copy(@dsid, @location)
      expect(ans).to be false
      expect(@dataset.is_on_disk?(@location)).to be true
    end

    it 'deletes the file locally' do
      @new_loc = {
        'silo' => 'sandbox',
        'dataset' => dataset_id,
        'filename' => 'test.txt',
        'url' => "http://10.0.0.173/sandbox/datasets/#{dataset_id}/test.txt" }
      @dataset.update_datastream_location(@dsid, @new_loc)
      @dataset.save!
      ans = @dataset.delete_local_copy(@dsid, @location)
      expect(ans).to be true
      expect(@dataset.is_on_disk?(@location)).to be false
    end

    end
    end
  end

  describe 'delete dir if empty' do
    it "is implemented but rspec add file not working" do
    skip "is skipped" do

    before do
      @dataset = Dataset.new
      @file = StringIO.new
      @file.write("Hello world!")
      @dsid = @dataset.add_content(@file, 'test.txt')
      dataset_id = @dataset.id.gsub('uuid:', '')
      @location = @dataset.file_location(@dsid)
      @new_loc = {
        'silo' => 'sandbox',
        'dataset' => dataset_id,
        'filename' => 'test.txt',
        'url' => "http://10.0.0.173/sandbox/datasets/#{dataset_id}/test.txt" }
      @dataset.update_datastream_location(@dsid, @new_loc)
      #@dataset.delete_local_copy(@dsid, @location)
      @dataset.save!
    end

    after do
      @dataset.delete
      File.delete('/tmp/test.txt')
    end

    it 'does not delete dir if not empty' do
      ans = @dataset.delete_dir
      #ans = @dataset.delete_local_copy(@dsid, @location)
      expect(ans).to be false
      expect(@dataset.is_on_disk?(@location)).to be true
    end

    it 'deletes dir if empty' do
      @dataset.delete_local_copy(@dsid, @location)
      ans = @dataset.delete_dir
      expect(ans).to be true
      expect(@dataset.is_on_disk?(@location)).to be false
    end

    end
    end
  end

  describe 'delete dir if forced and not empty' do
    it "is implemented but rspec add file not working" do
    skip "is skipped" do

    before do
      @dataset = Dataset.new
      @file = StringIO.new
      @file.write("Hello world!")
      @dsid = @dataset.add_content(@file, 'test.txt')
      @location = @dataset.file_location(@dsid)
      @dataset.save!
    end

    after do
      @dataset.delete
      File.delete('/tmp/test.txt')
    end

    it 'delete dir if forced and not empty' do
      expect(@dataset.is_on_disk?(@location)).to be true
      ans = @dataset.delete_dir(force=true)
      expect(ans).to be true
      expect(@dataset.is_on_disk?(@location)).to be true
    end

    end
    end
  end

end

require 'spec_helper'

describe GenericFilesController do
  before do
    @routes = Sufia::Engine.routes
    @user = FactoryGirl.find_or_create(:user)
    @generic_file = GenericFile.new
    @generic_file.apply_depositor_metadata(@user.user_key)
    GenericFile.any_instance.stub(:terms_of_service).and_return('1')
  end
  before (:each) do
    sign_in @user
    controller.stub(:clear_session_user) ## Don't clear out the authenticated session
    User.any_instance.stub(:groups).and_return([])
  end
  describe "update" do
    before do
      @generic_file.save
    end
    after do
      @generic_file.delete
    end
    it "should update workflows" do
      @generic_file.workflows.count.should == 1
      @generic_file.workflows.first.current_status.should == "Draft"
      @generic_file.workflows.first.entries.count.should == 1
      @generic_file.workflows.first.comments.count.should == 0
      workflow = @generic_file.workflows.first
      params = {
          "generic_file"=> {
              "workflows_attributes"=> [{
                  "id"=>workflow.rdf_subject.to_s, "identifier"=>"MediatedSubmission",
                  "entries_attributes"=>
                      [{"status"=>"Submitted", "date"=>"2013-07-05 16:23:32 +0100"}],
                  "comments_attributes"=>
                      [{"creator"=>"archivist1@example.com"}]}]
          }, "update_workflow"=>"", "id"=>@generic_file.noid}
      xhr :post, :update, params
      assigns(:generic_file).pid.should == @generic_file.pid
      assigns(:generic_file).workflows.count.should == 1
      wf = assigns(:generic_file).workflows.first
      wf.rdf_subject.should == workflow.rdf_subject
      wf.current_status.should == "Submitted"
      wf.entries.count.should == 2
      wf.comments.count.should == 1
      wf.comments.first.creator.should == ["archivist1@example.com"]      
    end
  end
end
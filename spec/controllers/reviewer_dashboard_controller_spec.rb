require 'spec_helper'

describe ReviewerDashboardController do
  before do
    GenericFile.any_instance.stub(:terms_of_service).and_return('1')
    User.any_instance.stub(:groups).and_return([])
    controller.stub(:clear_session_user) ## Don't clear out the authenticated session
  end
  
  describe "logged in archivist" do
    before (:each) do
      @user = FactoryGirl.find_or_create(:archivist)
      sign_in @user
      controller.stub(:clear_session_user) ## Don't clear out the authenticated session
      User.any_instance.stub(:groups).and_return([])
    end
    describe "#index" do
      before (:each) do
        xhr :get, :index
      end
      it "should be a success" do
        response.should be_success
        response.should render_template('reviewer_dashboard/index')
      end
      it "should return an array of documents that need to be reviewed" do
        expected_results = Blacklight.solr.get "select", :params=>{:q => "*:*", :fq=>["active_fedora_model_ssi:Article OR active_fedora_model_ssi:Dataset", "-MediatedSubmission_status_ssim:Approved", "-MediatedSubmission_status_ssim:Draft"]}
        assigns(:response)["response"]["numFound"].should eql(expected_results["response"]["numFound"])
      end
    end
  end
  
  describe "logged in regular user" do
    before (:each) do
      @user = FactoryGirl.find_or_create(:user)
      sign_in @user
      controller.stub(:clear_session_user) ## Don't clear out the authenticated session
      User.any_instance.stub(:groups).and_return([])
    end
    describe "#index" do
      it "should return an error" do
        xhr :post, :index
        response.should_not be_success
      end
    end
  end
  
  describe "not logged in as a user" do
    describe "#index" do
      it "should return an error" do
        xhr :post, :index
        response.should_not be_success
      end
    end
  end
end

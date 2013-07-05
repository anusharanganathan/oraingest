require 'spec_helper'

describe "Workflow Variations" do
  before do
    @routes = Sufia::Engine.routes
  end
  before(:all) do
    @user = FactoryGirl.find_or_create(:user)
    @archivist = FactoryGirl.find_or_create(:archivist)
    
    @draft = GenericFile.new(title:"Draft Submission", workflows_attributes:
                          {identifier:"MediatedSubmission", entries_attributes:{status:"Draft"}} )
    @draft.apply_depositor_metadata(@user.user_key)
    @submitted = GenericFile.new(title:"Submitted Item", workflows_attributes:
                          {identifier:"MediatedSubmission", entries_attributes:{status:"Submitted"}})
    @submitted.apply_depositor_metadata(@user.user_key)
    @in_review = GenericFile.new(title:"Item In Review", workflows_attributes:
                          {identifier:"MediatedSubmission", entries_attributes:{status:"Assigned", reviewer_id:@archivist.user_key}})
    @in_review.apply_depositor_metadata(@user.user_key)
    @escalated = GenericFile.new(title:"Item In Review", workflows_attributes:
                          {identifier:"MediatedSubmission", entries_attributes:{status:"Escalated", reviewer_id:@archivist.user_key}})
    @escalated.apply_depositor_metadata(@user.user_key)
    @approved = GenericFile.new(title:"Item In Review", workflows_attributes:
                          {identifier:"MediatedSubmission", entries_attributes:{status:"Approved", reviewer_id:@archivist.user_key}})
    @approved.apply_depositor_metadata(@user.user_key)
    @rejected = GenericFile.new(title:"Item In Review", workflows_attributes:
                          {identifier:"MediatedSubmission", entries_attributes:{status:"Rejected", reviewer_id:@archivist.user_key}})
    @rejected.apply_depositor_metadata(@user.user_key)

    [@draft, @submitted, @in_review, @escalated, @approved, @rejected].each {|o| o.save}
    
  end
  after(:all) do
    [@draft, @submitted, @in_review, @escalated, @approved, @rejected].each {|o| o.delete}
  end
  before do
    GenericFile.any_instance.stub(:terms_of_service).and_return('1')
  end
  describe DashboardController do
    describe "logged in user" do
      before (:each) do
        sign_in @user
        controller.stub(:clear_session_user) ## Don't clear out the authenticated session
        User.any_instance.stub(:groups).and_return([])
      end
      describe "#index" do
        before (:each) do
          xhr :get, :index, per_page:"100"
        end
        it "should be a success" do
          response.should be_success
          response.should render_template('dashboard/index')
        end
        it "should return an array of documents I can edit and include Submission status facet" do
          user_results = Blacklight.solr.get "select", :params=>{:fq=>["edit_access_group_ssim:public OR edit_access_person_ssim:#{@user.user_key}"]}
          assigns(:document_list).count.should eql(user_results["response"]["numFound"])
          ["Approved", "Assigned", "Draft", "Escalated", "Rejected", "Submitted"] .each do |statuses|
            assigns(:response).facet_fields["MediatedSubmission_status_ssim"].should include(statuses)
          end
        end
      end
    end
    describe "logged in as archivist" do
      before (:each) do
        sign_in @archivist
        controller.stub(:clear_session_user) ## Don't clear out the authenticated session
        User.any_instance.stub(:groups).and_return([])
      end
      describe "#index" do
        it "should not show other users content" do
          editable_results = Blacklight.solr.get "select", :params=>{:fq=>["edit_access_group_ssim:public OR edit_access_person_ssim:#{@archivist.user_key}"]}
          
          xhr :post, :index
          response.should be_success
          assigns(:result_set_size).should eql(editable_results["response"]["numFound"])
        end
      end
    end
  end
end

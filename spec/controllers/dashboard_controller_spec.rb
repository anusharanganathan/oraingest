require 'spec_helper'

describe DashboardController do
  before do
    GenericFile.any_instance.stub(:terms_of_service).and_return('1')
    User.any_instance.stub(:groups).and_return([])
    controller.stub(:clear_session_user) ## Don't clear out the authenticated session
  end
  describe "logged in user" do
    before (:each) do
      @user = FactoryGirl.find_or_create(:user)
      sign_in @user
      controller.stub(:clear_session_user) ## Don't clear out the authenticated session
      User.any_instance.stub(:groups).and_return([])
    end
    describe "#index" do
      before(:each) do
        xhr :get, :index
        # Make sure there are at least 3 files owned by @user. Otherwise, the tests aren't meaningful.
        if assigns(:document_list).count < 3
          files_count = assigns(:document_list).count
          until files_count == 3
            gf = GenericFile.new()
            gf.apply_depositor_metadata(@user.user_key)
            gf.save
            files_count += 1
          end
          xhr :get, :index
        end
      end
      
      it "should be a success" do
        response.should be_success
        response.should render_template('dashboard/index')
      end
      it "should return an array of documents I can edit" do
        user_results = Blacklight.solr.get "select", :params=>{:fq=>["edit_access_group_ssim:public OR edit_access_person_ssim:#{@user.user_key}"]}
        assigns(:document_list).count.should eql(user_results["response"]["numFound"])
      end
      context "with render views" do
        render_views
        it "should paginate" do          
          xhr :get, :index, per_page: 2
          response.should be_success
          response.should render_template('dashboard/index')
        end
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

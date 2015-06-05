require 'rails_helper'

describe GenericFilesController do
  before do
    @routes = Sufia::Engine.routes
    @user = FactoryGirl.find_or_create(:user)
    @generic_file = GenericFile.new
    @generic_file.apply_depositor_metadata(@user.user_key)
  end
  before (:each) do
    sign_in @user
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end
  describe 'update' do
    before do
      @generic_file.save
    end
    after do
      @generic_file.delete
    end
    it 'should update workflows' do
      expect(@generic_file.workflows.count).to eq(1)
      expect(@generic_file.workflows.first.current_status).to eq('Draft')
      expect(@generic_file.workflows.first.entries.count).to eq(1)
      expect(@generic_file.workflows.first.comments.count).to eq(0)
      workflow = @generic_file.workflows.first
      params = {
          'generic_file'=> {
              'workflows_attributes'=> [{
                  'id'=>workflow.rdf_subject.to_s, 'identifier'=>'MediatedSubmission',
                  'entries_attributes'=> [{
                                              'status'=>'Submitted', 'date'=>'2013-07-05 16:23:32 +0100'
                                          }],
                  'comments_attributes'=> [{
                                               'creator'=>'archivist1@example.com'
                                           }]
                                        }]
          },
          'update_workflow'=>'', 'id'=>@generic_file.noid
      }
      post :update, params
      expect(assigns(:generic_file).pid).to eq(@generic_file.pid)
      expect(assigns(:generic_file).workflows.count).to eq(1)
      wf = assigns(:generic_file).workflows.first
      expect(wf.rdf_subject).to eq(workflow.rdf_subject)
      expect(wf.current_status).to eq('Submitted')
      expect(wf.entries.count).to eq(2)
      expect(wf.comments.count).to eq(1)
      expect(wf.comments.first.creator).to eq(['archivist1@example.com'])      
    end
  end
end
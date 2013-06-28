describe ArticleController do

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[:article].should be_kind_of Article
       renders.should == "new"
    end
    it "should support create requests" do
       post :create, :article=>{"title"=>"My title"}
       ja = assigns[:article]
       ja.title.should == "My title"
    end
  end

  describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hydra:fixture_journal_article"
       assigns[:article].should be_kind_of Article
       assigns[:article].pid.should == "hydra:fixture_journal_article"
    end
    it "should support updating objects" do
       put :update, :article=>{"title"=>"My Newest Title"}
       ja = assigns[:article]
       ja.title.should == "My Newest Title"
    end
  end

end

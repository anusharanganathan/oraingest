describe JournalArticlesController do

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[:journal_article].should be_kind_of JournalArticle
       renders.should == "new"
    end
    it "should support create requests" do
       post :create, :journal_article=>{"title"=>"My title"}
       ja = assigns[:journal_article]
       ja.title.should == "My title"
    end
  end

  describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hydra:fixture_journal_article"
       assigns[:journal_article].should be_kind_of JournalArticle
       assigns[:journal_article].pid.should == "hydra:fixture_journal_article"
    end
    it "should support updating objects" do
       put :update, :journal_article=>{"title"=>"My Newest Title"}
       ja = assigns[:journal_article]
       ja.title.should == "My Newest Title"
    end
  end

end

class JournalArticlesController < ApplicationController
  def new
    debugger
    @journal_article = JournalArticle.new
  end

  def show
    @journal_article = JournalArticle.find(params[:id])
  end

  def edit
    @journal_article = JournalArticle.find(params[:id])
  end

  def update
    @journal_article = JournalArticle.find(params[:id])
    @journal_article.update_attributes(params[:journal_article])
    redirect_to :edit
  end

  def create
    debugger
    #@journal_article = JournalArticle.new
    @journal_article = JournalArticle.create(params[:journal_article])
    @journal_article.to_solr
    redirect_to :show
  end

end

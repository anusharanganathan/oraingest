class ArticleController < ApplicationController
  def new
    #debugger
    @article = Article.new
  end

  def show
    @article = Article.find(params[:id])
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    @article.update_attributes(params[:article])
    redirect_to :edit
  end

  def create
    #debugger
    #@article = Article.new
    @article = Article.new(params[:article])
    @article.to_solr
    redirect_to :show
  end

end

class Admin::NewsArticlesController < Admin::EditionsController

  private

  def edition_class
    NewsArticle
  end

  def requested_edition_id
    params[:news_article_id] || super
  end
end

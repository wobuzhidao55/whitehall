class Admin::WorldLocationNewsArticlesController < Admin::EditionsController

  private

  def edition_class
    WorldLocationNewsArticle
  end

  def requested_edition_id
    params[:world_location_news_article_id] || super
  end
end

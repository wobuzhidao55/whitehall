class Admin::WorldLocationNewsArticlesController < Admin::EditionsController

  private

  def edition_class
    WorldLocationNewsArticle
  end

  def find_edition
    edition = edition_class.find(params[:world_location_news_article_id] || params[:id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end
end

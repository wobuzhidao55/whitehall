class Admin::NewsArticlesController < Admin::EditionsController

  private

  def edition_class
    NewsArticle
  end

  def find_edition
    edition = edition_class.find(params[:news_article_id] || params[:id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end
end

class Admin::DocumentCollectionsController < Admin::EditionsController
  private

  def edition_class
    DocumentCollection
  end

  def find_edition
    edition = edition_class.find(params[:document_collection_id] || params[:id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end
end

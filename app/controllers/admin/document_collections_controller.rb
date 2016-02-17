class Admin::DocumentCollectionsController < Admin::EditionsController
  private

  def edition_class
    DocumentCollection
  end

  def requested_edition_id
    params[:document_collection_id] || super
  end
end

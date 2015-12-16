class Admin::GenericEditionsController < Admin::EditionsController
  private

  def edition_class
    GenericEdition
  end

  def find_edition
    edition = edition_class.find(params[:generic_edition_id] || params[:id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end
end

class Admin::DetailedGuidesController < Admin::EditionsController

private
  def edition_class
    DetailedGuide
  end

  def find_edition
    edition = edition_class.find(params[:detailed_guide_id] || params[:id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end
end

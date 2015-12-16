class Admin::CaseStudiesController < Admin::EditionsController

  private

  def edition_class
    CaseStudy
  end

  def find_edition
    edition = edition_class.find(params[:case_study_id] || params[:id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end
end

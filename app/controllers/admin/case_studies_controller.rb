class Admin::CaseStudiesController < Admin::EditionsController

  private

  def edition_class
    CaseStudy
  end

  def requested_edition_id
    params[:case_study_id] || super
  end
end

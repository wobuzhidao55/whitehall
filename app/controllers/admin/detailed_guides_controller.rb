class Admin::DetailedGuidesController < Admin::EditionsController

private
  def edition_class
    DetailedGuide
  end

  def requested_edition_id
    params[:detailed_guide_id] || super
  end
end

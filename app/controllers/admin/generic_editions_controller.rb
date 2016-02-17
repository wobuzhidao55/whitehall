class Admin::GenericEditionsController < Admin::EditionsController
  private

  def edition_class
    GenericEdition
  end

  def requested_edition_id
    params[:generic_edition_id] || super
  end
end

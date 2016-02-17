class Admin::StatisticalDataSetsController < Admin::EditionsController

  private

  def edition_class
    StatisticalDataSet
  end

  def requested_edition_id
    params[:statistical_data_set_id] || super
  end
end

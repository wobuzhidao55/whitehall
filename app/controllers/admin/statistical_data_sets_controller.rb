class Admin::StatisticalDataSetsController < Admin::EditionsController

  private

  def edition_class
    StatisticalDataSet
  end

  def find_edition
    edition = edition_class.find(params[:statistical_data_set_id] || params[:id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end
end

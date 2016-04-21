class SearchIndexDeleteWorker < WorkerBase

  attr_reader :link, :index

  def perform(link, index, request_id = nil)
    GdsApi::GovukHeaders.set_header(:govuk_request_id, request_id) if request_id
    Whitehall::SearchIndex.for(index.to_sym).delete(link)
  end
end

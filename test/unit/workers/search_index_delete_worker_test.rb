require 'test_helper'

class SearchIndexDeleteWorkerTest < ActiveSupport::TestCase

  test '#perform deletes the instance from its index' do
    index = mock('search_index')
    index.expects(:delete).with('woo')
    Whitehall::SearchIndex.expects(:for).with(:government).returns(index)

    SearchIndexDeleteWorker.new.perform('woo', 'government')
  end

  test '#perform takes an optional request_id' do
    assert_equal GdsApi::GovukHeaders.headers[:govuk_request_id], nil

    SearchIndexDeleteWorker.new.perform('woo', 'government', 'some-request-id')
    assert_equal GdsApi::GovukHeaders.headers[:govuk_request_id], 'some-request-id'
  end
end

require 'date'
require_relative "../../lib/date_time_for_publishing_api"
require "minitest/autorun"

class DateTimeForPublishingApiTest < MiniTest::Test
  def test_it_returns_nil_for_nil
    assert_nil DateTimeForPublishingApi.format(nil)
  end

  def test_it_raises_an_argument_error_for_non_date_base_types
    types = ["","string", 12345, true, {a: "1"}, :symbol, ["a", 1] ]

    types.each do |type|
      assert_raises ArgumentError do
        DateTimeForPublishingApi.format(type)
      end
    end
  end

  def test_it_returns_formatted_date_time_for_a_time
    time = Time.new(2012, 10, 31, 14, 25, 2, "+02:00")
    formatted_time = DateTimeForPublishingApi.format(time)
    assert_equal "2012-10-31T14:25:02.000+02:00", formatted_time
  end

  def test_it_returns_formatted_date_time_for_a_date
    date = Date.new(2016, 11, 29)
    formatted_datetime = DateTimeForPublishingApi.format(date)
    assert_equal "2016-11-29T00:00:00.000+00:00", formatted_datetime
   end
end

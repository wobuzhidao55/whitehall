class DateTimeForPublishingApi
  def self.format(dateish)
    return nil if dateish.nil?
    raise ArgumentError unless dateish.respond_to?("to_datetime")
    dateish.to_datetime.rfc3339(3)
  end
end

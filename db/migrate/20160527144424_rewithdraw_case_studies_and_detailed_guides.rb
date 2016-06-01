class RewithdrawCaseStudiesAndDetailedGuides < ActiveRecord::Migration
  def change
    [CaseStudy, DetailedGuide].each do |model_class|
      withdrawn = model_class.withdrawn
      withdrawn.each do |edition|
        unpublishing = edition.unpublishing
        explanation = unpublishing.try(:explanation)
        puts "Rewithdrawing: #{edition.content_id}, slug: #{edition.slug}, locale: #{edition.primary_locale}"
        puts "Explanation: #{explanation}"
        puts
        api.publish_withdrawal_async(edition.content_id, explanation, edition.primary_locale)
      end
    end
  end

  def api
    Whitehall::PublishingApi
  end
end

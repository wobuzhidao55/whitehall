task publishing_export: :environment do
  export_path = ENV["EXPORT_PATH"] || "#{Rails.root}/tmp/publishing_export.csv"

  require "csv"

  def print_progress(completed, total)
    percent_complete = ((completed.to_f / total) * 100).round
    percent_remaining = 100 - percent_complete

    return if percent_remaining < 0

    STDOUT.print "\r"
    STDOUT.flush
    STDOUT.print "Progress [#{"=" * percent_complete}>#{"." * percent_remaining}] (#{percent_complete}%)"
    STDOUT.flush
  end

  puts "Counting documents"
  scope = Document
  total_line_count = scope.count

  puts "Exporting documents.."
  CSV.open(export_path, "w") do |csv|
    csv << %w[whitehall_db_id content_id base_path locale state model updated_at]

    PolicyGroup.find_each do |item|
      csv << [item.id, item.content_id, "/government/groups/" + item.slug, "en", "n/a", item.class.name, item.updated_at]
    end

    Organisation.find_each do |item|
      if item.organisation_type_key == :court
        prefix = "/courts-tribunals/"
      else
        prefix = "/government/organisations/"
      end

      item.translations.each do |translation|
        base_path = prefix + item.slug
        base_path << ".#{translation.locale}" unless translation.locale == :en
        csv << [item.id, item.content_id, base_path, translation.locale, "n/a", item.class.name, item.updated_at]
      end
    end

    MinisterialRole.find_each do |item|
      csv << [item.id, item.content_id, "/government/ministers/" + item.slug, "en", "n/a", item.class.name, item.updated_at]
    end

    Person.find_each do |item|
      item.translations.each do |translation|
        base_path = "/government/people/" + item.slug
        base_path << ".#{translation.locale}" unless translation.locale == :en
        csv << [item.id, item.content_id, base_path, translation.locale, "n/a", item.class.name, item.updated_at]
      end
    end

    WorldLocation.find_each do |item|
      item.translations.each do |translation|
        base_path = "/government/world/" + item.slug
        base_path << ".#{translation.locale}" unless translation.locale == :en
        csv << [item.id, item.content_id, base_path, translation.locale, "n/a", item.class.name, item.updated_at]
      end
    end

    StatisticsAnnouncement.find_each do |item|
      csv << [item.id, item.content_id, "/government/statistics/announcements/" + item.slug, "en", "n/a", item.class.name, item.updated_at]
    end

    scope.find_each.with_index do |document, index|
      edition = document.latest_edition
      next if edition.nil?

      edition.translations.each do |translation|
        base_path = Whitehall.url_maker.public_document_path(edition, locale: translation.locale)
        csv << [edition.id, edition.content_id, base_path, translation.locale, edition.state, edition.class.name, edition.updated_at]
      end

      print_progress(index, total_line_count)
    end
  end
  puts
  puts "Exporting documents.. done."
end

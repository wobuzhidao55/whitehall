require "csv"

namespace :data_extractor do
  HEADERS = %w(
    document_slug
    document_content_id
    total_lead_organisations
    lead_organisations_content_ids
    lead_organisation_slugs
    supporting_organisations
    total_supporting_organisations
    supporting_organisations_content_ids
    supporting_organisations_slugs
  )

  def write_headers
    CSV.open("org_data.csv", "w+") do |csv|
      csv << HEADERS
    end
  end

  def has_orgs?(ed)
    return false if ed.class == CorporateInformationPage
    ed.supporting_organisations.any? || ed.lead_organisations.any?
  end

  def run!
    Edition.includes(:document).where.not(first_published_at: nil).find_in_batches do |group|
      group.select do |ed|
        write_edition_to_file(ed) if has_lead_or_supporting_orgs?(ed)
      end
    end
  end

  def write_edition_to_file(ed)
    data_hash = data_hash_for_edition(ed)
    puts "Saving data for #{ed.document.slug}"

    CSV.open("org_data.csv", "a+") do |csv|
      csv << data_hash.values
    end
  end

  def data_hash_for_edition(ed)
    {
      document_slug:                        ed.document.slug,
      document_content_id:                  ed.document.content_id,
      total_lead_organisations:             ed.lead_organisations.count,
      lead_organisations_content_ids:       lead_organisation_content_ids(ed),
      lead_organisation_slugs:              lead_organisation_slugs(ed),
      total_supporting_organisations:       ed.supporting_organisations.count,
      supporting_organisations_content_ids: supporting_organisations_content_ids(ed),
      supporting_organisations_slugs:       supporting_organisations_slugs(ed),
    }
  end

  def lead_organisation_slugs(ed)
    return unless ed.lead_organisations.any?
    ed.lead_organisations.map {|org| org.slug}.join(" ")
  end

  def lead_organisation_content_ids(ed)
    return unless ed.lead_organisations.any?
    ed.lead_organisations.map {|org| org.content_id}.join(" ")
  end

  def supporting_organisations_content_ids(ed)
    return unless ed.supporting_organisations.any?
    ed.supporting_organisations.map {|org| org.content_id}.join(" ")
  end

  def supporting_organisations_slugs(ed)
    return unless ed.supporting_organisations.any?
    ed.supporting_organisations.map {|org| org.slug}.join(" ")
  end

  def has_lead_or_supporting_orgs?(ed)
    return false if ed.class == CorporateInformationPage
    ed.supporting_organisations.any? || ed.lead_organisations.any?
  end

  desc "Extract document organisation data"
  task :organisations => :environment do
    write_headers
    run!
  end
end

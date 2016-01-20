require "csv"

namespace :data_extractor do
  HEADERS = %w(
    document_slug
    document_content_id
    type
    total_lead_organisations
    lead_organisations_content_ids
    lead_organisation_slugs
    total_supporting_organisations
    supporting_organisations_content_ids
    supporting_organisations_slugs
  )

  def write_headers
    CSV.open("org_data.csv", "w+") do |csv|
      csv << HEADERS
    end
  end

  def run!
    documents.each_with_index do |doc, i|
      write_edition_to_file(doc) if has_multiple_orgs? doc
      puts i if i % 100 == 0
    end
  end

  def documents
    return enum_for(:documents) unless block_given?

    Document.joins(:published_edition).includes(:published_edition).find_in_batches do |group|
      group.select do |doc|
        yield doc
      end
    end
  end

  def write_edition_to_file(doc)
    data_hash = data_hash_for_edition(doc)

    CSV.open("org_data.csv", "a+") do |csv|
      csv << data_hash.values
    end
  end

  def data_hash_for_edition(doc)
    lead_organisations = doc.published_edition.lead_organisations
    supporting_organisations = doc.published_edition.supporting_organisations

    {
      document_slug:                        doc.slug,
      document_content_id:                  doc.content_id,
      type:                                 doc.published_edition.type,
      total_lead_organisations:             lead_organisations.count,
      lead_organisations_content_ids:       organisation_content_ids(lead_organisations),
      lead_organisation_slugs:              organisation_slugs(lead_organisations),
      total_supporting_organisations:       supporting_organisations.count,
      supporting_organisations_content_ids: organisation_content_ids(supporting_organisations),
      supporting_organisations_slugs:       organisation_slugs(supporting_organisations),
    }
  end

  def organisation_slugs(organisations)
    organisations.map(&:slug).join(" ")
  end

  def organisation_content_ids(organisations)
    organisations.map(&:content_id).join(" ")
  end

  def has_multiple_orgs?(doc)
    ed = doc.published_edition
    return false if ed.class == CorporateInformationPage
    (ed.lead_organisations.count + ed.supporting_organisations.count) > 1
  end

  desc "Extract document organisation data"
  task organisations: :environment do
    write_headers
    run!
  end
end

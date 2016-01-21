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
    total_organisations
  )

  MINISTER_HEADERS = %w(
    document_slug
    document_content_id
    type
    total_role_appointments
    role_appointment_content_ids
    role_appointment_slugs
    total_ministerial_role_appointments
    ministerial_role_appointment_content_ids
    ministerial_role_appointment_slugs
  )

  def write_headers
    CSV.open("org_data.csv", "w+") do |csv|
      csv << HEADERS
    end
  end

  def write_minister_headers
    CSV.open("ministers_data.csv", "w+") do |csv|
      csv << MINISTER_HEADERS
    end
  end

  def run!
    puts "TOTAL: #{documents.count}"
    documents.find_each.with_index do |doc, i|
      lead_organisations = doc.published_edition.lead_organisations
      supporting_organisations = doc.published_edition.supporting_organisations
      if has_multiple_orgs?(doc, lead_organisations, supporting_organisations)
        write_edition_to_file(doc, lead_organisations, supporting_organisations)
      end
      puts i if i % 100 == 0
    end
  end

  def run_ministers!
    puts "TOTAL: #{minister_documents.count}"
    minister_documents.find_each.with_index do |doc, i|
      next unless doc.published_edition.respond_to?(:role_appointments)
      appointments = doc.published_edition.role_appointments
      if appointments.length > 1
        write_edition_to_ministers_file(doc, appointments)
      end
      puts i if i % 100 == 0
    end
  end

  def documents
    Document
      .joins(:published_edition)
      .where("editions.type != 'CorporateInformationPage'")
      .includes(published_edition: [:organisations])
  end

  def minister_documents
    Document
      .joins(:published_edition)
  end

  def write_edition_to_file(doc, lead_organisations, supporting_organisations)
    data_hash = data_hash_for_edition(doc, lead_organisations, supporting_organisations)

    CSV.open("org_data.csv", "a+") do |csv|
      csv << data_hash.values
    end
  end

  def write_edition_to_ministers_file(doc, ministers)
    data_hash = ministers_data_hash_for_edition(doc, ministers)

    CSV.open("ministers_data.csv", "a+") do |csv|
      csv << data_hash.values
    end
  end

  def data_hash_for_edition(doc, lead_organisations, supporting_organisations)
    {
      document_slug:                        doc.slug,
      document_content_id:                  doc.content_id,
      type:                                 doc.published_edition.type,
      total_lead_organisations:             lead_organisations.count,
      lead_organisations_content_ids:       extract_content_ids(lead_organisations),
      lead_organisation_slugs:              extract_slugs(lead_organisations),
      total_supporting_organisations:       supporting_organisations.count,
      supporting_organisations_content_ids: extract_content_ids(supporting_organisations),
      supporting_organisations_slugs:       extract_slugs(supporting_organisations),
      total_organisations:                  lead_organisations.count + supporting_organisations.count
    }
  end

  def ministers_data_hash_for_edition(doc, role_appointments)
    people = role_appointments.map(&:person)
    ministerial = role_appointments.select {|ra| ra.role.is_a? MinisterialRole}
    ministers = ministerial.map(&:person)
    {
      document_slug:                             doc.slug,
      document_content_id:                       doc.content_id,
      type:                                      doc.published_edition.type,
      total_role_appointments:                   role_appointments.count,
      role_appointments_content_ids:             extract_content_ids(people),
      role_appointments_slugs:                   extract_slugs(people),
      total_ministerial_role_appointments:       ministers.count,
      ministerial_role_appointments_content_ids: extract_content_ids(ministers),
      ministerial_role_appointments_slugs:       extract_slugs(ministers),
    }
  end

  def extract_slugs(content_items)
    content_items.map(&:slug).join(" ")
  end

  def extract_content_ids(content_items)
    content_items.map(&:content_id).join(" ")
  end

  def has_multiple_orgs?(doc, lead_organisations, supporting_organisations)
    ed = doc.published_edition
    return false if ed.class == CorporateInformationPage
    (lead_organisations.count + supporting_organisations.count) > 1
  end

  desc "Extract document organisation data"
  task organisations: :environment do
    write_headers
    run!
  end

  task ministers: :environment do
    write_minister_headers
    run_ministers!
  end

end

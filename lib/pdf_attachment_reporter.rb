require 'csv'

class PDFAttachmentReporter

  include ActionView::Helpers::NumberHelper

  attr_reader :data_path, :start_date, :end_date

  def initialize(opts={})
    @data_path  = opts.fetch(:data_path, ENV['HOME'])
    @start_date = opts.fetch(:start_date, Date.parse('2000-01-01'))
    @end_date   = opts.fetch(:end_date, Date.today)
  end

  def pdfs_by_organisation
    jan_2016_date = Date.parse('2016-01-01')
    thirty_days_ago_date = 30.days.ago.to_date

    live_organisations = Organisation.where(govuk_status: 'live')

    live_organisation_published_pdfs_total_counts_hash = Hash[live_organisations.map { |o| [o.name, 0] }]
    live_organisation_published_pdfs_jan_2016_counts_hash = Hash[live_organisations.map { |o| [o.name, 0] }]
    live_organisation_published_pdfs_last_30_days_counts_hash = Hash[live_organisations.map { |o| [o.name, 0] }]

    unique_published_pdf_attachments.each do |attachment|
      edition = Edition.find_by(id: attachment.attachable_id)

      if edition
        first_published_version = find_first_published_version(edition)

        if first_published_version
          pdf_owning_organisation = guess_organisation_owner_of_edition(edition)

          if pdf_owning_organisation.class == Organisation && pdf_owning_organisation.live?

            live_organisation_published_pdfs_total_counts_hash[pdf_owning_organisation.name] += 1

            if first_published_version.created_at >= thirty_days_ago_date
              live_organisation_published_pdfs_last_30_days_counts_hash[pdf_owning_organisation.name] += 1
            end

            if first_published_version.created_at >= jan_2016_date
              live_organisation_published_pdfs_jan_2016_counts_hash[pdf_owning_organisation.name] += 1
            end
          end
        end
      end
    end

    CSV.open(csv_file_path('overview'), 'wb') do |csv|
      csv << [
        "Organisation",
        "Total published PDF attachments",
        "Jan 2016 - present PDF attachments",
        "Last 30 days PDF attachments"
      ]

      live_organisations.each do |organisation|
        csv << [
          organisation.name,
          live_organisation_published_pdfs_total_counts_hash[organisation.name],
          live_organisation_published_pdfs_jan_2016_counts_hash[organisation.name],
          live_organisation_published_pdfs_last_30_days_counts_hash[organisation.name]
        ]
      end
    end
  end

  def report
    CSV.open(csv_file_path, 'wb') do |csv|
      csv << ["Slug", "Organisations", "Total attachments", "Accessible attachments", "Content types", "Combined size"]
      published_editions_with_attachments.each do |edition|
        csv << [edition.document.slug, edition.organisations.map(&:name).join(","), edition.attachments.size,
          accessible_details(edition.attachments), content_type_details(edition.attachments),
          combined_attachments_file_size(edition.attachments)]
      end
    end
  end

private
  def find_first_published_version(edition)
    edition_versions = edition.document_version_trail.map(&:object)
    edition_versions.detect { |version| version.state == 'published' }
  end

  def guess_organisation_owner_of_edition(edition)
    # We select a parent organisation as the owner if all of the associated
    # organisations are related to each other, otherwise we default to the first
    # organisation.

    all_organisations_related = true

    orgs_sorted_by_parent = edition.organisations.sort do |org1, org2|
      if org1.parent_organisations.ids.include? org2.id
        1
      elsif org2.parent_organisations.ids.include? org1.id
        -1
      else
        all_organisations_related = false
        0
      end
    end

    all_organisations_related ? orgs_sorted_by_parent.first : edition.organisations.first
  end

  def unique_published_pdf_attachments
    Attachment.find_by_sql([
      "SELECT a.*
       FROM attachments a
       INNER JOIN attachment_data ad
       ON a.attachment_data_id=ad.id
       WHERE a.attachable_type = 'Edition'
       AND a.created_at BETWEEN ? AND ?
       AND ad.content_type = ?
       GROUP BY ad.id", start_date, end_date, AttachmentUploader::PDF_CONTENT_TYPE
    ])
  end

  def accessible_count(attachments)
    attachments.inject(0) { |sum, a| sum += a.accessible ? 1 : 0 }
  end

  def accessible_details(attachments)
    count = accessible_count(attachments)
    "#{count} (#{percentage(count, attachments.size)})"
  end

  def content_type_details(attachments)
    attachments.delete_if { |a| a.attachment_data.nil? }
    grouped_attachments = attachments.group_by { |a| a.attachment_data.content_type }
    "".tap do |buf|
      grouped_attachments.each do |mime_type, collection|
        buf << "#{mime_type} : #{collection.size}\n"
      end
    end
  end

  def combined_attachments_file_size(attachments)
    file_sizes = attachments.map do |a|
      a.attachment_data ? a.attachment_data.file_size : 0
    end
    file_sizes.sum
  end

  def percentage(number, total)
    number_to_percentage((number.to_f / total) * 100)
  end

  def csv_file_path(report_type='report')
    File.join(data_path, "attachments-#{report_type}-#{Time.zone.now.strftime("%y%m%d-%H%M%S")}.csv")
  end
end


require 'csv'

class PDFAttachmentReporter
  POLICY_GROUPS = 'Policy Groups'.freeze

  attr_reader :data_path

  def initialize(opts={})
    @data_path  = opts.fetch(:data_path, ENV['HOME'])
    @start_date = Date.parse('2015-01-01')
    @end_date = Date.parse('2015-02-01')
  end

  # Notes on limitations of the report
  # 1. We do not track the times at which policy group attachments were made
  # 2. Attachments which are associated with Worldwide organisations are not 
  #    counted

  def pdfs_by_organisation
    jan_2016_date = Date.parse('2015-01-01')
    thirty_days_ago_date = 300.days.ago.to_date

    live_organisation_names = Organisation.where(govuk_status: 'live').map(&:name) << POLICY_GROUPS

    live_organisation_published_pdfs_total_counts_hash = Hash[live_organisation_names.map { |o| [o, 0] }]
    live_organisation_published_pdfs_jan_2016_counts_hash = Hash[live_organisation_names.map { |o| [o, 0] }]
    live_organisation_published_pdfs_last_30_days_counts_hash = Hash[live_organisation_names.map { |o| [o, 0] }]

    unique_published_pdf_attachments.each do |attachment|
      pdf_attachment_data = find_pdf_attachment_data(attachment)

      if pdf_attachment_data
        live_organisation_published_pdfs_total_counts_hash[pdf_attachment_data.owning_organisation_name] += 1

        if pdf_attachment_data.created_at >= thirty_days_ago_date
          live_organisation_published_pdfs_last_30_days_counts_hash[pdf_attachment_data.owning_organisation_name] += 1
        end

        if pdf_attachment_data.created_at >= jan_2016_date
          live_organisation_published_pdfs_jan_2016_counts_hash[pdf_attachment_data.owning_organisation_name] += 1
        end
      end
    end

    CSV.open(csv_file_path('overview'), 'wb') do |csv|
      csv << [
        "Organisation",
        "Total published PDF attachments",
        "Jan 2015 - present PDF attachments",
        "Last 300 days PDF attachments"
      ]

      live_organisation_names.each do |organisation_name|
        csv << [
          organisation_name,
          live_organisation_published_pdfs_total_counts_hash[organisation_name],
          live_organisation_published_pdfs_jan_2016_counts_hash[organisation_name],
          live_organisation_published_pdfs_last_30_days_counts_hash[organisation_name]
        ]
      end
    end
  end


private
  class PDFAttachmentData
    attr_reader :owning_organisation_name, :created_at

    def initialize(owning_organisation_name, created_at)
      @owning_organisation_name = owning_organisation_name
      @created_at = created_at
    end
  end

  def find_pdf_attachment_data(attachment)
    attachable_object = find_attachable_object(attachment)

    puts "finding stuff for attachment #{attachment.id}"

    if attachable_object
      if attachable_object.class == PolicyGroup
        PDFAttachmentData.new(POLICY_GROUPS, attachment.created_at)
      else
        if attachable_object.kind_of?(Response)
          if attachable_object.consultation
            pdf_owning_organisation = guess_organisation_owner_of_edition(attachable_object.consultation)
            first_published_version = find_first_published_version(attachable_object.consultation)
          end
        else
          pdf_owning_organisation = guess_organisation_owner_of_edition(attachable_object)
          first_published_version = find_first_published_version(attachable_object)
        end

        if pdf_owning_organisation && pdf_owning_organisation.live? &&
           first_published_version && first_published_version.created_at
          PDFAttachmentData.new(pdf_owning_organisation.name, first_published_version.created_at)
        else
          nil
        end
      end
    end
  end

  def find_attachable_object(attachment)
    attachable_type = attachment.attachable_type.constantize
    attachable_type.find_by_id(attachment.attachable_id)
  end

  def find_first_published_version(edition)
    edition_versions = edition.document_version_trail.map(&:object)
    edition_versions.detect { |version| version.state == 'published' }
  end

  def guess_organisation_owner_of_edition(edition)
    all_organisation_ids = edition.organisations.map(&:id)

    # If there is at least one unrelated organisation, assume the first organisation in the list is the owner
    if any_organisations_unrelated?(edition, all_organisation_ids)
      edition.organisations.find { |org| org.class == Organisation }
    else
      # If all organisations are related, use the parent organisation as the owner
      edition.organisations.find do |org|
        (org.parent_organisation_ids & all_organisation_ids).none?
      end
    end
  end

  def any_organisations_unrelated?(edition, all_organisation_ids)
    edition.organisations.any? do |org|
      (org.class != Organisation) || ((org.child_organisation_ids + org.parent_organisation_ids) & all_organisation_ids).none?
    end
  end

  def unique_published_pdf_attachments
    Attachment.find_by_sql([
      "SELECT a.*
       FROM attachments a
       INNER JOIN attachment_data ad
       ON a.attachment_data_id=ad.id
       WHERE a.created_at BETWEEN ? AND ?
       AND ad.content_type = ?
       GROUP BY ad.id", start_date, end_date, AttachmentUploader::PDF_CONTENT_TYPE
    ])
  end

  def csv_file_path(report_type='report')
    File.join(data_path, "attachments-#{report_type}-#{Time.zone.now.strftime("%y%m%d-%H%M%S")}.csv")
  end
end

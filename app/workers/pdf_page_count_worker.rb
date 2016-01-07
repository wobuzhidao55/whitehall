require 'pdf-reader'

class PDFPageCountWorker < WorkerBase
  def perform(attachment_data_id, pdf_string)
    attachment_data = AttachmentData.find(attachment_data_id)
    attachment_data.update_attributes(
      number_of_pages: calculate_number_of_pages(pdf_string)
    )
  end

private

  def calculate_number_of_pages(pdf_string)
    PDF::Reader.new(StringIO.new(pdf_string)).page_count
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
    return nil
  end
end

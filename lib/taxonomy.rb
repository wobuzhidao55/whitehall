module Taxonomy
  def self.education
    @education ||= begin
      filename = Rails.root + "lib/taxonomy/education.json"
      taxonomy = JSON.parse(File.read(filename))
      $stderr.puts taxonomy
      $stderr.puts taxonomy["links"]["child_taxons"]
      taxonomy
    end
  end
end

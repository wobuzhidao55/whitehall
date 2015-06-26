# Once this has been successfully run in production it can be deleted.
namespace :election do
  desc "Publishes policy papers that were converted from worldwide priorities."
  task :publish_policy_papers => :environment do
    mapping_csv_path = Rails.root+"lib/tasks/election/policy_paper_creation_output.csv"

    unless File.exist?(mapping_csv_path)
      puts "Please copy the CSV output from running https://github.com/alphagov/whitehall/pull/2223 to #{mapping_csv_path}"
    end

    policy_paper_ids = CSV.parse(File.open(mapping_csv_path).read, headers: true).map do |row|
      row["policy_paper_id"]
    end

    require_relative "election/policy_paper_publisher"
    Election::PolicyPaperPublisher.new(policy_paper_ids).run!
  end
end

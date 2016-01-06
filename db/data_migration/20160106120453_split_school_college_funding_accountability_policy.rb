# old policy content_id (School and college funding an accountability): "5e11d7d1-7631-11e4-a3cb-005056011aef"
# new policy #1 - School and college accountability - content_id: "453affe4-5ebb-4f44-9f0a-44cfd32dc934"
# new policy #2 - School and college funding - content_id: "17e4ab26-ee1f-4383-a345-d165c0b75fbf"


# artefact = RegisterableEdition.new(published_edition)
# registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'whitehall', rendering_app: 'whitehall-frontend', kind: artefact.kind)
# puts "Registering /#{artefact.slug} with Panopticon..."
# registerer.register(artefact)
#
# puts "Registering /#{artefact.slug} with Search..."
# Whitehall::SearchIndex.add(document.published_edition)

require "csv"
csv_file = File.join(File.dirname(__FILE__), "20160106120453_split_school_college_funding_accountability_policy.csv")

csv = CSV.parse(File.open(csv_file), headers: true)

csv.first(2).each do |row|
  slug = row["slug"]
  old_policy_content_id = row["old_policy_content_id"]
  new_policy_content_ids = row["new_policy_content_ids"].split(" ")

  document = Document.where(slug: slug)

  binding.pry
  unless document
    puts "Document does not exist, slug: #{slug}"
    next
  end

end

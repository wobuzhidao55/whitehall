# # namespace :untag_from_policy do
# #   desc "Untag all documents from given policy"
# #   editions = Edition.where(title: "Academies financial notices to improve")
# # end
#
# namespace :tag_to_policy do
#   desc "Tag all given documents to given policy"
#   # find edition with wanted title, might want with wanted slug
#   editions = Edition.where(title: "Academies financial notices to improve")
#   # we want to find all previous editions, even the ones that had a different title
#   editions = editions.last.editions
#
#
#
#   # find its editions, tag to wanted edition
#   policies = editions.map do |edition|
#     edition.edition_policies
#   end
#
#
# end
#
# class PolicyTaggingManager
#   attr_reader
#   def initialize(edition, policy)
#   end
#
#   def tag
#     # add policy to edition
#   end
#
#   def untag
#     # remove policy from edition
#   end
# end
# '''
# Item 1
#
# "Academies financial notices to improve"	"/government/collections/academies-financial-notices-to-improve"	"Collection"
#
# Collection of documents.
#
# Is it only the set tagged to the policy or also the documents?
#
# doc = Document.where(slug: "academies-financial-notices-to-improve").count => 1
# DocumentCollection.where(title: "Academies financial notices to improve").count => 25
# Edition.where(title: "Academies financial notices to improve").count => 25
#
# A document has many editions:
# doc.editions.count => 25
#
# Document can`t be tagged to a related policy. Neither do Editions. DocumentCollection can.
#
# editions = doc.editions
# edition_policies = edition.edition_policies
# edition_policies.delete(EditionPolicy.find("5e11d7d1-7631-11e4-a3cb-005056011aef"))
#
# -
#
# '''

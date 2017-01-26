module Admin::EditionTagsHelper
  def checkbox_for_taxonomy(selected_taxon_content_ids, taxon)
    checked = selected_taxon_content_ids.include?(taxon["content_id"])

    check_box_tag(
      "edition_taxonomy_tag_form[taxons][]",
      taxon["content_id"],
      checked,
      id: taxon["content_id"]
    )
  end
end

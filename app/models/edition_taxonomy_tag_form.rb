class EditionTaxonomyTagForm
  include ActiveModel::Model

  attr_accessor :selected_taxons, :edition_content_id, :previous_version

  def self.load(content_id)
    content_item = Whitehall
      .publishing_api_v2_client
      .get_links(content_id)

    new(
      selected_taxons: content_item["links"]["taxons"] || [],
      edition_content_id: content_id,
      previous_version: content_item["version"] || 0
    )
  end

  def publish!
    Whitehall
      .publishing_api_v2_client
      .patch_links(
        edition_content_id,
        links: { taxons: taxons_to_publish },
        previous_version: previous_version
      )
  end

  def taxons_to_publish
    education_taxons.tree.each_with_object([]) do |taxon, list_of_taxons|
      content_ids = taxon.descendants.map(&:content_item).map do |content_item|
        content_item["content_id"]
      end

      any_descendants_selected = selected_taxons.any? do |selected_taxon|
        content_ids.include?(selected_taxon)
      end

      unless any_descendants_selected
        content_id = taxon.content_item["content_id"]
        list_of_taxons << content_id if selected_taxons.include?(content_id)
      end
    end
  end

  def education_taxons
    Taxonomy.education
  end
end

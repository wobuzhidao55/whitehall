class ExpandedLinksFetcher
  attr_accessor :content_id

  def initialize(content_id)
    @content_id = content_id
  end

  def fetch
    ExpandedLinks.new(
      Whitehall
        .publishing_api_v2_client
        .get_expanded_links(content_id)
      )
  end

  class ExpandedLinks
    def initialize(publishing_api_response)
      @response = publishing_api_response
    end

    def selected_taxon_paths
      response["expanded_links"].fetch("taxons", []).map {|taxon_hash| taxon_path(taxon_hash)}
    end

  private

    attr_reader :response

    # TODO: reuse https://raw.githubusercontent.com/alphagov/govuk_navigation_helpers/master/lib/govuk_navigation_helpers/taxon_breadcrumbs.rb
    def taxon_path(taxon_hash)
      parents = [{title: taxon_hash["title"]}]


      direct_parents = taxon_hash["links"]["parent_taxons"]
      while direct_parents
        # There should not be more than one parent for a taxon. If there is,
        # make an arbitrary choice.
        direct_parent = direct_parents.first

        parents << {title: direct_parent["title"]}

        direct_parents = direct_parent["links"]["parent_taxons"]
      end

      parents.reverse
    end

  end
end

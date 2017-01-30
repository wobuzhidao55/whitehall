class Admin::EditionTagsController < Admin::BaseController
  before_filter :find_edition
  before_filter :enforce_permissions!
  before_filter :limit_edition_access!
  before_action :redirect_back, unless: :tagging_taxonomy_enabled?

  def edit
    @edition_tag_form = EditionTaxonomyTagForm.load(@edition.content_id)

    # expanded_links = Whitehall
    #       .publishing_api_v2_client
    #       .get_expanded_links(@edition.content_id)
    #
    # @breadcrumbs = expand_parents(expanded_links)
  end

  def update
    @edition_tag_form = EditionTaxonomyTagForm.new(
      edition_content_id: @edition.content_id,
      selected_taxons: params["edition_taxonomy_tag_form"]["taxons"].reject(&:blank?),
      previous_version: params["edition_taxonomy_tag_form"]["previous_version"]
    )

    @edition_tag_form.publish!
    redirect_to edit_admin_edition_tags_path(@edition),
      notice: "The tags have been updated."
  rescue GdsApi::HTTPConflict
    redirect_to edit_admin_edition_tags_path(@edition),
      alert: "Somebody changed the tags before you could. Your changes have not been saved."
  end

private


  def expand_parents(content_item_expanded_links)
    content_item_expanded_links["expanded_links"]["parent_taxons"].map do |direct_parent|
      breadcrumb = []
      while direct_parent
        breadcrumb << direct_parent

        direct_parent = direct_parent["links"]["parent_taxons"].first
      end

      breadcrumb
    end
  end

  def redirect_back
    if request.env["HTTP_REFERER"].blank?
      redirect_to admin_root_path
    else
      redirect_to :back
    end
  end

  def enforce_permissions!
    unless @edition.can_be_tagged_to_taxonomy?
      raise Whitehall::Authority::Errors::PermissionDenied.new(:update, @edition)
    end

    enforce_permission!(:update, @edition)
  end

  def find_edition
    edition = Edition.find(params[:edition_id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end
end

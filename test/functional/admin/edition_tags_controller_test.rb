require 'test_helper'

class Admin::EditionTagsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @user = login_as(:departmental_editor)
    @publishing_api_endpoint = GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT
    organisation = create(:organisation, content_id: "ebd15ade-73b2-4eaf-b1c3-43034a42eb37")
    @edition = create(:publication, organisations: [organisation])
    @parent_taxon = "47b6ce42-0bfa-42ee-9ff1-7a9c71ee9727"
    @child_taxon = "e16b62e0-9c54-4547-b8c0-7589d8af3906"
  end

  def stub_publishing_api_links_with_taxons(content_id, taxons)
    publishing_api_has_links(
      {
        "content_id" => content_id,
        "links" => {
          "taxons" => taxons
        },
        "version" => 1
      }
    )
  end

  test 'should return an error on a version conflict' do
    publishing_api_patch_request = stub_request(:patch, "#{@publishing_api_endpoint}/links/#{@edition.content_id}")
      .to_return(status: 409)

    put :update, edition_id: @edition, edition_taxonomy_tag_form: { previous_version: 1, taxons: [@child_taxon] }

    assert_requested publishing_api_patch_request
    assert_redirected_to edit_admin_edition_tags_path(@edition)
    assert_equal "Somebody changed the tags before you could. Your changes have not been saved.", flash[:alert]
  end

  test 'should only post the child taxon to publishing-api when both a child taxon and its parent are selected' do
    stub_publishing_api_links_with_taxons(@edition.content_id, [])

    put :update, edition_id: @edition, edition_taxonomy_tag_form: { taxons: [@parent_taxon, @child_taxon], previous_version: 1 }

    assert_publishing_api_patch_links(@edition.content_id, links: { taxons: [@child_taxon] }, previous_version: "1")
  end

  test 'should post the child taxon to publishing-api when only a child taxon is selected' do
    stub_publishing_api_links_with_taxons(@edition.content_id, [])

    put :update, edition_id: @edition, edition_taxonomy_tag_form: { taxons: [@child_taxon], previous_version: 1 }

    assert_publishing_api_patch_links(@edition.content_id, links: { taxons: [@child_taxon] }, previous_version: "1")
  end

  view_test 'should check a child taxon and its parents when only a child taxon is returned' do
    stub_publishing_api_links_with_taxons(@edition.content_id, [@child_taxon])

    get :edit, edition_id: @edition

    assert_select "input[value='#{@parent_taxon}'][checked='checked']"
    assert_select "input[value='#{@child_taxon}'][checked='checked']"
  end

  view_test 'should check a parent taxon but not its children when only a parent taxon is returned' do
    stub_publishing_api_links_with_taxons(@edition.content_id, [@parent_taxon])

    get :edit, edition_id: @edition

    assert_select "input[value='#{@parent_taxon}'][checked='checked']"
    refute_select "input[value='#{@child_taxon}'][checked='checked']"
  end
end

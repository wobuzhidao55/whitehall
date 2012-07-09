require 'test_helper'

class DocumentHelperTest < ActionView::TestCase
  test "#edition_organisation_class returns the slug of the first organisation of the edition" do
    organisations = [create(:organisation), create(:organisation)]
    edition = create(:edition, organisations: organisations)
    assert_equal organisations.first.slug, edition_organisation_class(edition)
  end

  test '#edition_organisation_class returns "no_organisation" if doc has no organisation' do
    edition = create(:edition)
    assert_equal 'unknown_organisation', edition_organisation_class(edition)
  end

  test "should generate a national statistics logo for a national statistic" do
    publication = create(:publication, publication_type_id: PublicationType::NationalStatistics.id)
    assert_match /National Statistic/, national_statistics_logo(publication)
  end

  test "should generate no national statistics logo for an edition that is not a national statistic" do
    publication = create(:publication)
    refute_match /National Statistic/, national_statistics_logo(publication)
  end
end

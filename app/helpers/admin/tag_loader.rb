# coding: utf-8
class Admin::TagLoader
  def initialize(edition)
    @edition = edition
    @links = Whitehall.publishing_api_v2_client.get_links(@edition.content_id).try(:links)
    # somehow '/topic' gets set as a topic...
    # remove content_id for '/topic'
    if links
      links[:topics] = links[:topics] - ["76e9abe7-dac8-49f0-bb5e-53e4b0d2cdba"]
    end
  end

  def load_tags_for_edition
    return edition unless links

    edition.tap do |e|
      if e.respond_to? :worldwide_priorities=
        e.worldwide_priorities = links.worldwide_priorities ? WorldPriority.where(content_id: links.worldwide_priorities) : []
      end
      if e.respond_to? :world_locations=
        e.world_locations = links.world_locations ? WorldLocation.where(content_id: links.world_locations) : []
      end
      if e.respond_to? :lead_organisation_ids=
        e.lead_organisation_ids = links.lead_organisations ? Organisation.where(content_id: links.lead_organisations).map(&:id) : []
      end
      if e.respond_to?(:supporting_organisation_ids=)
        e.supporting_organisation_ids = []
      end
      if e.respond_to? :worldwide_organisations=
        e.worldwide_organisations = links.worldwide_organisations ? WorldwideOrganisation.where(content_id: links.worldwide_organisations) : []
      end
      if e.respond_to? :policy_content_ids=
        e.policy_content_ids = links.related_policies ? links.related_policies : []
      end
      if e.respond_to? :primary_specialist_sector_tag=
        e.primary_specialist_sector_tag = links.topics.present? ? Whitehall.publishing_api_v2_client.get_content(links.topics.first).to_hash["base_path"].gsub('/topic/', '') : ""
      end
      if e.respond_to? :secondary_specialist_sector_tags=
        e.secondary_specialist_sector_tags = secondary_specialist_sector_tags(links)
      end
      if e.respond_to? :topic_ids=
        e.topic_ids = policy_areas(links)
      end
      if e.respond_to? :topical_event_ids=
        e.topical_event_ids = links.topical_events ? [] : []
      end

      e.save
      e.reload
    end
  end

  private

  attr_reader :links, :edition

  def policy_areas(links)
    if links.policy_areas.present?
      links.policy_areas.map do |content_id|
        Topic.where(slug: get_slug(content_id)).first.id
      end
    else
      []
    end
  end

  def secondary_specialist_sector_tags(links)
    if links.topics.present?
      links.topics[1..-1].map do |content_id|
        get_slug(content_id)
      end
    else
      []
    end
  end

  def get_slug(content_id)
    Whitehall.publishing_api_v2_client.get_content(content_id).to_hash["base_path"].gsub('/topic/', '')
  end
end

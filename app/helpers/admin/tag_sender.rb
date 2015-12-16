# coding: utf-8
require 'pp'

class Admin::TagSender
  def initialize(content_id, raw_values)
    @content_id = content_id
    @raw_values = raw_values # beware: some raw_values are already content_ids...
  end

  def send_tags
    send_content_ids(process_raw_values)
  end

  private

  attr_reader :content_id

  def send_content_ids(data)
    Whitehall.publishing_api_v2_client.put_links(content_id, data)
  end

  def process_raw_values
    processed = {}

    @raw_values.each do |k, v|
      processed[k] = v.is_a?(Array) ? v.select(&:present?) : v
    end

    topic_content_ids = processed["secondary_specialist_sector_tags"].unshift(processed["primary_specialist_sector_tag"]).map do |tag|
      Whitehall.content_store.content_item!("/topic/#{tag}").content_id
    end

    policy_area_ids = if processed["topic_ids"]
                        Topic.find(processed["topic_ids"]).map do |topic|
                          Whitehall.content_store.content_item!("/topic/#{topic.slug}").content_id
                        end
                      else
                        []
                      end

    links = {}
    links[:topics] = topic_content_ids
    # keep supporting_organisations here for completeness, but all orgs are mapped to, and considered ordered on, lead_organisations
    links[:lead_organisations] = processed["lead_organisation_ids"] ? Organisation.find(processed["lead_organisation_ids"]).map(&:content_id) : []
    links[:supporting_organisations] = processed["supporting_organisation_ids"] ? Organisation.find(processed["supporting_organisation_ids"]).map(&:content_id) : []
    # is Document.find correct for DocumentCollections?
    links[:document_collections] = processed["document_collections"] ? Document.find(processed["document_collections"]).map(&:content_id) : []
    links[:related_policies] = processed["policy_content_ids"] ? processed["policy_content_ids"] : []
    links[:world_locations] = processed["world_location_ids"] ? WorldLocation.find(processed["world_location_ids"]).map(&:content_id) : []
    links[:worldwide_priorities] = processed["worldwide_priorities"] ? WorldPriority.find(processed["worldwide_priorities"]).map(&:content_id) : []
    links[:policy_areas] = policy_area_ids
    links[:worldwide_organisations] = processed["worldwide_organisation_ids"] ? WorldwideOrganisation.find(processed["worldwide_organisation_ids"]).map(&:content_id) : []
    links[:statistical_data_set_documents] = processed["statistical_data_set_document_ids"] ? StatisticalDataSet.where(document_id: processed["statistical_data_set_document_ids"]).map(&:content_id) : []

    { links: links }.tap { |x| PP.pp x }
  end
end

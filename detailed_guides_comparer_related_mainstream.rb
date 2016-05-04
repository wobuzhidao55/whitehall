#!/usr/bin/env ruby

#For pre-migration detailed guides, this script compares titles of linked mainstream content in the content store (automatically fetched from Mainstream publisher), vs. in Whitehall (manually entered by editors)

require "csv"
require "json"
require "gds_api/content_store"
require "pry"

class FoundContentItem

  attr_reader :title

  def initialize(mainstream_base_path)
    mainstream_base_path = strip_subpart(mainstream_base_path) if has_subpart?(mainstream_base_path) && is_not_mainstream?(mainstream_base_path) == false
    content_store = GdsApi::ContentStore.new(Plek.new.find('content-store'))
    response = content_store.content_item(mainstream_base_path) || {"title" => "missing", "base_path" => "missing"}
    if is_not_mainstream?(response["base_path"])
      @title = "NOT MAINSTREAM" + response["title"].rstrip
    elsif response["title"].nil?
      enhanced_base_path = "/guidance" + mainstream_base_path
      response = content_store.content_item(enhanced_base_path) || {"title" => "missing", "base_path" => "missing"}
      @title = response["title"] || "content_item found, title missing"
    else
      @title = response["title"].rstrip
    end
  end

  def has_subpart?(base_path)
    base_path[1..-1].include?("/") if base_path.class == String && base_path[1..-1]
  end

  def strip_subpart(base_path)
    base_path[/.*\//][0..-2]
  end

  def is_not_mainstream?(base_path)
    base_path.start_with?("/government") || base_path.start_with?("/guidance")
  end

end

p "starting"

n = 0
@whitehall_results = {}
@content_store_results = {}
@dg_with_related_mainstream_title_discrepancies = {}

p "Do you want to compare related mainstream (type r) or additional related mainstream?(type a)"

input = gets.chomp

if input == "r"
  detailed_guides = DetailedGuide.published.select{|dg| dg.has_related_mainstream_content?}
elsif input == "a"
  detailed_guides = DetailedGuide.published.select{|dg| dg.has_additional_related_mainstream_content? }
else
  detailed_guides = nil
  p "bye"
end

def get_base_path(url)
  url.slice!("https://www.gov.uk")
  url
end

detailed_guides.each do |dgr|
  dg_base_path = "/guidance/" + dgr.slug
  @whitehall_results[dg_base_path] = {
    title: dgr.related_mainstream_content_title.rstrip,
    mainstream_base_path: get_base_path(dgr.related_mainstream_content_url)
  }
end


@whitehall_results.each do |base_path, wh_mainstream_content|
  cs_mainstream_content = FoundContentItem.new(wh_mainstream_content[:mainstream_base_path])
  if cs_mainstream_content.title != wh_mainstream_content[:title] &&
    @dg_with_related_mainstream_title_discrepancies[base_path]={
      wh_title: wh_mainstream_content[:title],
      cs_title: cs_mainstream_content.title
    }
  else
    p "."
  end
end

def with_nil_cs_title(list)
  list.select{|bp, titles| titles[:cs_title] == "content_item found, title missing"}
end

def with_cs_title_missing(list)
  list.select{|bp, titles| titles[:cs_title] == "missing" }
end

def with_cs_title(list)
  list.reject{ |k,v| with_cs_title_missing(list).has_key?(k) && with_nil_cs_title(list).has_key?(k)}
end

p "Number of discrepancies: #{@dg_with_related_mainstream_title_discrepancies.count}"
p "Number of discrepancies with nil cs title: #{with_nil_cs_title(@dg_with_related_mainstream_title_discrepancies).count}"
p "Number of discrepancies with cs title missing: #{with_cs_title_missing(@dg_with_related_mainstream_title_discrepancies).count}"
p "Do you want the full list? y for yes"
input = gets.chomp
p "Detailed Guide Base Path, Whitehall Title, Content Store Title"
  [with_cs_title(@dg_with_related_mainstream_title_discrepancies), with_nil_cs_title(@dg_with_related_mainstream_title_discrepancies), (with_nil_cs_title(@dg_with_related_mainstream_title_discrepancies))].each do |sublist|
    sublist.each do |base_path, titles|
        p "#{base_path}, #{titles[:wh_title]}, #{titles[:cs_title]}"
    end
  end

p "done"

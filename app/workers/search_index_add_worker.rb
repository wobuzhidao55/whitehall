class SearchIndexAddWorker < WorkerBase

  attr_reader :id, :class_name

  def perform(class_name, id)
    @class_name = class_name
    @id = id

    if searchable_instance.nil?
      Rails.logger.warn("SearchIndexAddWorker: Could not find #{class_name} with id #{id} (#{Time.zone.now.utc.to_s}).")
    elsif !searchable_instance.can_index_in_search?
      Rails.logger.warn("SearchIndexAddWorker: Was asked to index #{class_name} with id #{id}, but it was unindexable (#{Time.zone.now.utc.to_s}).")
    else
      if searchable_instance.is_a?(Edition)
        if public_url_changed_from_previous_edition?
          previous_url = searchable_instance.previous_edition.search_link
          # TODO will this raise an error if it has already been deleted?
          index.delete(previous_url)
        end
      end
      index.add(searchable_instance.search_index)
    end
  end

private
  def index
    @_index = Whitehall::SearchIndex.for(searchable_instance.rummager_index)
  end

  def searchable_instance
    @searchable_instance ||= searchable_class.find_by(id: id)
  end

  def searchable_class
    if searchable_class_names.include?(class_name)
      class_name.constantize
    else
      raise ArgumentError, "#{class_name} is not a searchable class"
    end
  end

  def searchable_class_names
    Whitehall.searchable_classes.map(&:name)
  end
end

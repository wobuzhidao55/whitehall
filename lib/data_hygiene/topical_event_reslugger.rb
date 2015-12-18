module DataHygiene
  class TopicalEventReslugger
    def initialize(topical_event, new_slug)
      @topical_event = topical_event
      @new_slug = new_slug
      @old_slug = @topical_event.slug
    end

    def run!
      remove_from_search_index
      update_slug
      update_editions
      # topical_events aren't sent to the publishing-api at all, but this will
      # use the publishing-api to create redirects in the router
      register_redirect
    end

  private
    attr_reader :topical_event, :new_slug, :old_slug

    def remove_from_search_index
      # The about pages aren't in search, so we just need to do the
      # topical_event itself
      Whitehall::SearchIndex.delete(topical_event)
    end

    def update_slug
      # Note: This will trigger calls to rummager meaning that an entry will
      # exist with the correct slug.
      topical_event.update_attributes!(slug: new_slug)
    end

    def update_editions
      # Update the topical event tag against each of associated the published
      # things in search
      topical_event.editions.published.each(&:update_in_search_index)
    end

    def old_base_path
      Whitehall.url_maker.topical_event_path(old_slug)
    end

    def new_base_path
      Whitehall.url_maker.topical_event_path(new_slug)
    end

    def redirects
      # Redirect the:
      #  - base_path
      #  - atom feed
      #  - the /about page (which feels a bit wrong, because they might be their
      #                     own content item when we migrate them...)
      redirects = [{ path: old_base_path, destination: new_base_path, type: "exact" }]
      redirects << { path: (old_base_path + ".atom"),
                     destination: (new_base_path + ".atom"),
                     type: "exact" }
      redirects << { path: (old_base_path + "/about"),
                     destination: (new_base_path + "/about"),
                     type: "exact" }
      redirects
    end

    def register_redirect
      Whitehall::PublishingApi.publish_redirect_async(old_base_path, redirects)
    end
  end
end

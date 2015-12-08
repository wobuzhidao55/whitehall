# For now, this is used to register data for items in the content
# store as "placeholder" content items. This is so that finders can reference
# items using content_ids and have their basic information expanded
# out when read back out from the content store.
class PublishingApiPresenters::OrganisationPlaceholder < PublishingApiPresenters::Placeholder

  private

  def details
    super.merge({
      abbreviation: item.abbreviation
    })
  end
end

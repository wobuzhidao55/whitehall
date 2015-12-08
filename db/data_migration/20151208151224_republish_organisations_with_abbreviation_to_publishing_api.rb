require 'data_hygiene/publishing_api_republisher'

DataHygiene::PublishingApiRepublisher.new(Organisation.all).perform

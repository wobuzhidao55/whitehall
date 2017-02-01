module SyncChecker
  module Formats
    class NewsArticleCheck < EditionBase
      def expected_details_hash(news_article)
        super.tap do |details|
          details.reject { |k, _| k == :emphasised_organisations }
          details.merge!(expected_government(edition))
          details.merge!(expected_political(edition))
          details.merge!(expected_tags(edition))
          #include image!!
        end
      end
    end

    def rendering_app
      Whitehall::RenderingApp::GOVERNMENT_FRONTEND
    end

    def root_path
      '/government/news/'
    end


    private


    def expected_government(news_article)
      return {} unless news_article.government

      {
        'government' => {
          'title' => consultation.government.name,
          'slug' => consultation.government.slug,
          'current' => consultation.government.current?
        }
      }
    end

    def expected_political(news_article)
      { political: news_article.political? }
    end

    # def expected_tags(news_article)
    #   policies = if news_article.can_be_related_to_policies?
    #                news_article.policies.map(&:slug)
    #              end
    #
    #   topics = Array(news_article.primary_specialist_sector_tag) +
    #     consultation.secondary_specialist_sector_tags
    #
    #   {
    #     'tags' => {
    #       'browse_pages' => [],
    #       'policies' => policies.compact,
    #       'topics' => topics.compact,
    #     }
    #   }
    # end
  end
end

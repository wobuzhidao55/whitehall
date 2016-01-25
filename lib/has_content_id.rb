module HasContentId
  extend ActiveSupport::Concern

  included do
    before_validation :generate_content_id, on: :create
    validates :content_id, presence: true
  end

private

  def generate_content_id
    self.content_id = SecureRandom.uuid
  end
end

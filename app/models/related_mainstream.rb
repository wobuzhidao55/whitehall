class RelatedMainstream < ActiveRecord::Base
  belongs_to :edition
  validates :content_id, presence: true, uniqueness: true
  validates :edition_id, presence: true
end

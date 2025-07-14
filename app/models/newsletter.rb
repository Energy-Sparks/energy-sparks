# == Schema Information
#
# Table name: newsletters
#
#  created_at    :datetime         not null
#  created_by_id :bigint(8)
#  id            :bigint(8)        not null, primary key
#  published     :boolean          default(FALSE), not null
#  published_on  :date             not null
#  title         :text             not null
#  updated_at    :datetime         not null
#  updated_by_id :bigint(8)
#  url           :text             not null
#
# Indexes
#
#  index_newsletters_on_created_by_id  (created_by_id)
#  index_newsletters_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (updated_by_id => users.id) ON DELETE => nullify
#

class Newsletter < ApplicationRecord
  include Publishable
  include Trackable

  scope :without_images, -> {
    left_outer_joins(:image_attachment).where(active_storage_attachments: { id: nil })
  }

  has_one_attached :image

  validates_presence_of :title, :url, :published_on
  validates :image,
    content_type: ['image/png', 'image/jpeg'],
    dimension: { width: { min: 300, max: 1400 } } # betwen 300 (existing images) and full container width size to be conservative

  def publishable?
    image.attached?
  end

  def self.publishable_error_without
    'without image'
  end
end

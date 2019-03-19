# == Schema Information
#
# Table name: find_out_more_types
#
#  alert_type_id :bigint(8)        not null
#  created_at    :datetime         not null
#  description   :string           not null
#  id            :bigint(8)        not null, primary key
#  rating_from   :integer          not null
#  rating_to     :integer          not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_find_out_more_types_on_alert_type_id  (alert_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_id => alert_types.id) ON DELETE => restrict
#

class FindOutMoreType < ApplicationRecord
  belongs_to :alert_type
  has_many :content_versions, class_name: 'FindOutMoreTypeContentVersion'

  scope :for_rating, ->(rating) { where('rating_from <= ? AND rating_to >= ?', rating, rating) }

  def current_content
    content_versions.latest.first
  end
end

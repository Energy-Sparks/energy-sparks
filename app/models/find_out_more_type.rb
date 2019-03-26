# == Schema Information
#
# Table name: find_out_more_types
#
#  alert_type_id :bigint(8)        not null
#  created_at    :datetime         not null
#  description   :string           not null
#  id            :bigint(8)        not null, primary key
#  rating_from   :decimal(, )      not null
#  rating_to     :decimal(, )      not null
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

  validates :rating_from, :rating_to, :description, presence: true
  validates :rating_from, :rating_to, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  def current_content
    content_versions.latest.first
  end

  def update_with_content!(attributes, content)
    to_replace = current_content
    self.attributes = attributes
    if valid? && content.valid?
      save_and_replace(content, to_replace)
      true
    else
      false
    end
  end


private

  def save_and_replace(content, to_replace)
    transaction do
      save!
      content.save!
      to_replace.update!(replaced_by: content) if to_replace
    end
  end
end

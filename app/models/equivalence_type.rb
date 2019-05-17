# == Schema Information
#
# Table name: equivalence_types
#
#  created_at  :datetime         not null
#  id          :bigint(8)        not null, primary key
#  meter_type  :integer          not null
#  time_period :integer          not null
#  updated_at  :datetime         not null
#

class EquivalenceType < ApplicationRecord
  has_many :content_versions, class_name: 'EquivalenceTypeContentVersion'

  enum meter_type: [:electricity, :heat]
  enum time_period: {
    last_week: 10,
    last_school_week: 15,
    last_month: 20,
    last_year: 30
  }

  validates :meter_type, :time_period, presence: true

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

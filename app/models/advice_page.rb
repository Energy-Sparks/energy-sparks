# == Schema Information
#
# Table name: advice_pages
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  key        :string           not null
#  restricted :boolean          default(FALSE)
#  updated_at :datetime         not null
#
# Indexes
#
#  index_advice_pages_on_key  (key) UNIQUE
#
class AdvicePage < ApplicationRecord
  extend Mobility
  include TransifexSerialisable

  translates :learn_more, backend: :action_text

  has_many :advice_page_activity_types
  has_many :activity_types, through: :advice_page_activity_types

  has_many :advice_page_intervention_types
  has_many :intervention_types, through: :advice_page_intervention_types

  accepts_nested_attributes_for :advice_page_activity_types, reject_if: proc {|attributes| attributes['position'].blank? }

  accepts_nested_attributes_for :advice_page_intervention_types, reject_if: proc {|attributes| attributes['position'].blank? }

  scope :by_key, -> { order(key: :asc) }

  enum fuel_type: [:electricity, :gas, :storage_heater, :solar_pv]

  def update_activity_type_positions!(position_attributes)
    transaction do
      advice_page_activity_types.destroy_all
      update!(advice_page_activity_types_attributes: position_attributes)
    end
  end

  def update_intervention_type_positions!(position_attributes)
    transaction do
      advice_page_intervention_types.destroy_all
      update!(advice_page_intervention_types_attributes: position_attributes)
    end
  end
end

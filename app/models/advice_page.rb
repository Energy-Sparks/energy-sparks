# == Schema Information
#
# Table name: advice_pages
#
#  created_at      :datetime         not null
#  fuel_type       :integer
#  id              :bigint(8)        not null, primary key
#  key             :string           not null
#  multiple_meters :boolean          default(FALSE), not null
#  restricted      :boolean          default(FALSE)
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_advice_pages_on_key  (key) UNIQUE
#
class AdvicePage < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  include Enums::FuelType

  translates :learn_more, backend: :action_text

  has_many :alert_types
  has_many :advice_page_activity_types
  has_many :activity_types, through: :advice_page_activity_types

  has_many :advice_page_intervention_types
  has_many :intervention_types, through: :advice_page_intervention_types
  has_many :advice_page_school_benchmarks

  accepts_nested_attributes_for :advice_page_activity_types, reject_if: proc {|attributes| attributes['position'].blank? }

  accepts_nested_attributes_for :advice_page_intervention_types, reject_if: proc {|attributes| attributes['position'].blank? }

  scope :by_key, -> { order(key: :asc) }

  # Required as multiple is not yet supported in advice page list
  # Could be used for the total energy use page.
  def self.display_fuel_types
    fuel_types.reject {|k, _v| k.to_sym == :multiple}
  end

  def label
    key.humanize
  end

  def t_fuel_type
    fuel_type_key = fuel_type == 'solar_pv' ? 'electricity' : fuel_type
    I18n.t("advice_pages.fuel_type.#{fuel_type_key}")
  end

  def ordered_activity_types
    activity_types.order('advice_page_activity_types.position').group('activity_types.id, advice_page_activity_types.position')
  end

  def ordered_intervention_types
    intervention_types.order('advice_page_intervention_types.position').group('intervention_types.id, advice_page_intervention_types.position')
  end

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

  # Check whether school has the fuel type for this advice page
  # Defaults to treating unknown/nil fuel type as applicable to
  # all schools
  def school_has_fuel_type?(school, default_value: true)
    case fuel_type&.to_sym
    when :gas
      school.has_gas?
    when :electricity
      school.has_electricity?
    when :storage_heater
      school.has_storage_heaters?
    when :solar_pv
      # The check here is for electricity as a
      # "potential benefits" page is instead shown
      # for all schools with electricity but without
      # solar pv
      school.has_electricity?
    else
      default_value
    end
  end
end

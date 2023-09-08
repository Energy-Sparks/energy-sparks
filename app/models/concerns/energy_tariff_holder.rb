# Should be included by classes that tariff holders
module EnergyTariffHolder
  extend ActiveSupport::Concern
  class InvalidAppliesToError < StandardError; end

  included do
    has_many :energy_tariffs, as: :tariff_holder, dependent: :destroy
  end

  def site_settings?
    is_a?(SiteSettings)
  end

  def school_group?
    is_a?(SchoolGroup)
  end

  def school?
    is_a?(School)
  end

  def energy_tariff_meter_attributes(meter_type = EnergyTariff.meter_types.keys, applies_to: :both)
    raise InvalidAppliesToError unless EnergyTariff.applies_tos.key?(applies_to.to_s)

    applies_to_keys = [:both, applies_to].uniq

    energy_tariffs.enabled.where(meter_type: meter_type, applies_to: applies_to_keys).usable.map(&:meter_attribute)
  end

  def parent_tariff_holder
    nil
  end

  #Does it currently have any of that type
  def any_tariffs_of_type?(meter_type, source = :manually_entered, only_enabled: false)
    if only_enabled
      energy_tariffs.where(meter_type: meter_type, source: source, enabled: true).any?
    else
      energy_tariffs.where(meter_type: meter_type, source: source).any?
    end
  end

  #Can if have tariffs of a type
  def holds_tariffs_of_type?(_meter_type)
    true
  end

  def tariff_holder_i18n_key
    self.class.name.underscore&.to_sym
  end

  def default_tariff_start_date(meter_type, source = :manually_entered)
    latest_with_fixed_dates = energy_tariffs.latest_with_fixed_end_date(meter_type, source).first
    if latest_with_fixed_dates.present?
      latest_with_fixed_dates.end_date + 1.day
    else
      Time.zone.today
    end
  end

  def all_energy_tariff_attributes(meter_type = EnergyTariff.meter_types.keys, applies_to = :both)
    raise InvalidAppliesToError unless EnergyTariff.applies_tos.key?(applies_to.to_s)

    attributes = []
    parent = parent_tariff_holder
    attributes += parent.all_energy_tariff_attributes(meter_type, applies_to) unless parent.nil?
    attributes += energy_tariff_meter_attributes(meter_type, applies_to)
    attributes
  end
end

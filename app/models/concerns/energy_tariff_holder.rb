# Should be included by classes that tariff holders
module EnergyTariffHolder
  extend ActiveSupport::Concern

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

  def energy_tariff_meter_attributes(meter_type = EnergyTariff.meter_types.keys)
    energy_tariffs.where(meter_type: meter_type).complete.map(&:meter_attribute)
  end

  def parent_tariff_holder
    nil
  end

  #Does it currently have any of that type
  def any_tariffs_of_type?(meter_type, source = :manually_entered)
    energy_tariffs.where(meter_type: meter_type, source: source).any?
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

  def all_energy_tariff_attributes(meter_type = EnergyTariff.meter_types.keys)
    attributes = []
    parent = parent_tariff_holder
    attributes += parent.all_energy_tariff_attributes(meter_type) unless parent.nil?
    attributes += energy_tariff_meter_attributes(meter_type)
    attributes
  end
end

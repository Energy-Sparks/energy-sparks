# Should be included by classes that tariff holders
module EnergyTariffHolder
  extend ActiveSupport::Concern

  included do
    has_many :energy_tariffs, as: :tariff_holder, dependent: :destroy

    #All candidate tariffs are:
    #those with open start and end
    #those with earlier start and later end
    #those with start and end within start/end
    #those with open start and fixed end which is >= start
    #those with open end and fixed start which is <= end
    #enabled
    #usable
  end

  def tariffs_within_dates(meter_type, start_date, end_date)
    energy_tariffs.enabled.where(meter_type: meter_type).where(
      #open range, or wider
      "((start_date is NULL OR start_date <= :start_date) AND (end_date is NULL OR end_date >= :end_date))" +
      #narrower tariff, within range
      "OR (start_date >= :start_date AND end_date <= :end_date) " +
      #tariff starts early but ends within range
      "OR (start_date <= :start_date AND end_date <= :end_date) " +
      #tariff ends later, but starts within range
      "OR (end_date >= :end_date AND start_date <= :end_date) ", start_date: start_date, end_date: end_date
    ).order(created_at: :desc).usable
  end

  def all_tariffs_within_dates(meter_type, start_date, end_date)
    tariffs = tariffs_within_dates(meter_type, start_date, end_date)
    parent = parent_tariff_holder
    while parent != nil
      tariffs += parent.tariffs_within_dates(meter_type, start_date, end_date)
      parent = parent.parent_tariff_holder
    end
    tariffs
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
    energy_tariffs.enabled.where(meter_type: meter_type).usable.map(&:meter_attribute)
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

  def all_energy_tariff_attributes(meter_type = EnergyTariff.meter_types.keys)
    attributes = []
    parent = parent_tariff_holder
    attributes += parent.all_energy_tariff_attributes(meter_type) unless parent.nil?
    attributes += energy_tariff_meter_attributes(meter_type)
    attributes
  end
end

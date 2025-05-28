# frozen_string_literal: true

# https://www.catalyst-commercial.co.uk/dcp228-duos-charges/
# https://en.wikipedia.org/wiki/Electricity_billing_in_the_UK/
#
# Due to be replaced by a fixed charge from April 2022
#
# Distributed use of system charges are charged by time of day / weekday/weekend
# for use of the distribution network, labelled either 'red', 'amber' or 'green' times
# to reflect network capacity required to service the grid during peak (red) periods
#
class DUOSCharges
  class UnknownDBORegionException < StandardError; end
  class MissingDuosSetting        < StandardError; end

  def self.band(mpan, date, half_hour_index)
    region = region_number(mpan)
    daytype = DateTimeHelper.weekend?(date) ? :weekends : :weekdays
    band_by_region_daytype(region, daytype, half_hour_index)
  end

  def self.regional_charge_table(mpan)
    region = region_number(mpan)
    DUOS_BY_REGION[region]
  end

  def self.kwh_in_bands_between_dates(meter, start_date, end_date)
    band_kwh = {}
    (start_date..end_date).each do |date|
      (0..47).each do |hhi|
        band = DUOSCharges.band(meter.mpxn, date, hhi)
        band_kwh[band] ||= 0.0
        band_kwh[band] += meter.amr_data.kwh(date, hhi)
      end
    end
    band_kwh
  end

  def self.kwhs_x48(mpan, date, kwh_x48)
    band_kwhs_x48 = {}

    (0..47).each do |hhi|
      band = DUOSCharges.band(mpan, date, hhi)
      band_kwhs_x48[band] ||= Array.new(48, 0.0)
      band_kwhs_x48[band][hhi] = kwh_x48[hhi]
    end

    band_kwhs_x48
  end

  def self.check_for_completion_test
    banding = {}
    (10..23).each do |region|
      banding[region] = { name: DUOS_BY_REGION[region][:name], weekdays: [], weekends: [] }
      mpan = region * 100_000_000_000
      (0..47).each do |hhi|
        banding[region][:weekdays].push(DUOSCharges.band(mpan, Date.new(2021, 6, 4), hhi))
        banding[region][:weekends].push(DUOSCharges.band(mpan, Date.new(2021, 6, 5), hhi))
      end
    end
    banding
  end

  # reused by tnuos class
  def self.region_number(mpan)
    region = (mpan / 100_000_000_000).to_i
    DUOS_BY_REGION.key?(region) ? region : :fallback
  end

  private

  # generated from spreadsheet \Google Drive\Energy Sparks\Energy Sparks Project Team Documents\Analytics\Cost analysis\Duos charges\duos charges.xlsx
  # which was cutted and pasted from https://www.catalyst-commercial.co.uk/dcp228-duos-charges/
  # with corrections from https://www.ofgem.gov.uk/sites/default/files/docs/2009/09/appendix-c_illustrative-charges-and-time-bands_0.pdf
  # region 16, weekends 12:30 => 16:30
  DASH = '–' # the dash on the spreadsheet is not a minus sign

  DUOS_BY_REGION = {
    10 => { name: 'Eastern (EELC)',
            bands: { red: { weekdays: '16:00 – 19:00 ' },
                     amber: { weekdays: '07:00 – 16:00 & 19:00 – 23:00 '  },
                     green: { weekdays: '00:00 – 07:00 & 23:00 – 24:00 ', weekends: 'all day' } } },
    11 => { name: 'Western Power – Midlands, South West & Wales (EMEB)',
            bands: { red: { weekdays: '16:00 – 19:00 ' },
                     amber: { weekdays: '07:30 – 16:00 & 19:00 – 21:00 '  },
                     green: { weekdays: '00:00 – 07:30 & 21:00 – 24:00 ', weekends: 'all day' } } },
    12 => { name: 'London Power (LOND)',
            bands: { red: { weekdays: '11:00 – 14:00 & 16:00 – 19:00 ' },
                     amber: { weekdays: '07:00 – 11:00 & 14:00 – 16:00 & 19:00 – 23:00 ' },
                     green: { weekdays: '00:00 – 07:00 & 23:00 – 24:00 ', weekends: 'all day' } } },
    13 => { name: 'Manweb (MANW)',
            bands: { red: { weekdays: '16:30 – 19:30 ' },
                     amber: { weekdays: '08:00 – 16:30 & 19:30 – 22:30 ', weekends: '16:00 – 20:00' },
                     green: { weekdays: '00:00 – 08:00 & 22:30 – 24:00 ', weekends: '00:00 – 16:00 & 20:00 – 24:00' } } },
    14 => { name: 'Western Power – Midlands, South West & Wales (MIDE)',
            bands: { red: { weekdays: '16:00 – 19:00 ' },
                     amber: { weekdays: '07:30 – 16:00 & 19:00 – 21:00 '  },
                     green: { weekdays: '00:00 – 07:30 & 21:00 – 24:00 ', weekends: 'all day' } } },
    15 => { name: 'NorthEast (NEEB)',
            bands: { red: { weekdays: '16:00 – 19:30 ' },
                     amber: { weekdays: '08:00 – 16:00 & 19:30 – 22:00 '  },
                     green: { weekdays: '00:00 – 08:00 & 22:00 – 24:00 ', weekends: 'all day' } } },
    16 => { name: 'North West (NORW)',
            bands: { red: { weekdays: '16:30 – 18:30 & 19:30 – 22:00 ' },
                     amber: { weekdays: '09:00 – 16:30 & 18:30 – 20:30 ', weekends: '16:30 – 18:30' },
                     green: { weekdays: '00:00 – 09:00 & 20:30 – 24:00 ', weekends: '00:00 – 16:30 & 18:30 – 24:00' } } },
    17 => { name: 'Scottish Hydro (HYDE)',
            bands: { red: { weekdays: '12:30 – 14:30 & 16:30 – 21:00 ' },
                     amber: { weekdays: '07:00 – 12:30 & 14:30 – 16:30 ', weekends: '12:30 – 14:00 & 17:30 – 20:30' },
                     green: { weekdays: '00:00 – 07:00 & 21:00 – 24:00 ', weekends: '00:00 – 12:30 & 14:00 – 17:30 & 20:30 – 24:00' } } },
    18 => { name: 'Scottish Power (SPOW)',
            bands: { red: { weekdays: '16:30 – 19:30 ' },
                     amber: { weekdays: '08:00 – 16:30 & 19:30 – 22:30 ', weekends: '16:00 – 20:00' },
                     green: { weekdays: '00:00 – 08:00 & 22:30 – 24:00 ', weekends: '00:00 – 16:00 & 20:00 – 24:00' } } },
    19 => { name: 'South Eastern (SEEB)',
            bands: { red: { weekdays: '16:00 – 19:00 ' },
                     amber: { weekdays: '07:00 – 16:00 & 19:00 – 23:00 '  },
                     green: { weekdays: '00:00 – 07:00 & 23:00 – 24:00 ', weekends: 'all day' } } },
    20 => { name: 'Southern Electric (SOUT)',
            bands: { red: { weekdays: '16:30 – 19:00 ' },
                     amber: { weekdays: '09:00 – 16:30 & 19:00 – 20:30 '  },
                     green: { weekdays: '00:00 – 09:00 & 20:30 – 24:00 ', weekends: 'all day' } } },
    21 => { name: 'Western Power – Midlands, South West & Wales (SWALEC)',
            bands: { red: { weekdays: '17:00 – 19:30 ' },
                     amber: { weekdays: '07:30 – 17:00 & 19:30 – 22:00 ', weekends: '12:00 – 13:00 & 16:00 – 21:00' },
                     green: { weekdays: '00:00 – 07:30 & 22:00 – 24:00 ', weekends: '00:00 – 12:00 & 13:00 – 16:00 & 21:00 – 24:00' } } },
    22 => { name: 'Western Power – Midlands, South West & Wales (SWEB)',
            bands: { red: { weekdays: '17:00 – 19:00 ' },
                     amber: { weekdays: '07:30 – 17:00 & 19:00 – 21:30 ', weekends: '16:30 – 19:30' },
                     green: { weekdays: '00:00 – 7:30 & 21:30 – 24:00 ', weekends: '00:00 – 16:30 & 19:30 – 24:00' } } },
    23 => { name: 'NorthEast (YELG)',
            bands: { red: { weekdays: '16:00 – 19:30 ' },
                     amber: { weekdays: '08:00 – 16:00 & 19:30 – 22:00 '  },
                     green: { weekdays: '00:00 – 08:00 & 22:00 – 24:00 ', weekends: 'all day' } } },
    :fallback => { name: 'Fallback for IDNOs',
                   bands: {
                      red: { weekdays: '' },
                      amber: { weekdays: ''  },
                      green: { weekdays: '', weekends: '' }
                    }
    }
  }.freeze
  private_constant :DUOS_BY_REGION

  private_class_method def self.band_by_region_daytype(region, daytype, half_hour_index)
    @@band ||= {}
    colour_band = @@band.dig(region, daytype, half_hour_index)
    return colour_band unless colour_band.nil?

    cached_band(region, daytype)[half_hour_index] ||= calculate_band(region, daytype, half_hour_index)
  end

  private_class_method def self.cached_band(region, daytype)
    @@band[region] ||= {}
    @@band[region][daytype] ||= {}
  end

  private_class_method def self.calculate_band(region, daytype, half_hour_index)
    DUOS_BY_REGION[region][:bands].each do |band, band_info|
      return band if band_info.key?(daytype) && in_time_range?(band_info[daytype], half_hour_index)
    end
    # Part of work around for IDNOs return nil for now rather than fail
    # raise MissingDuosSetting, "Missing Duos setting for region: #{region} at/on #{daytype} half hour #{half_hour_index}"
    return nil
  end

  private_class_method def self.in_time_range?(times, half_hour_index)
    tod = TimeOfDay.time_of_day_from_halfhour_index(half_hour_index)
    tod_ranges = time_ranges(times)
    tod_ranges.each do |tod_range|
      return true if tod >= tod_range.first && tod <= tod_range.last
    end
    false
  end

  private_class_method def self.time_ranges(times)
    @@time_ranges ||= {}
    return @@time_ranges[times] if @@time_ranges.key?(times)

    @@time_ranges[times] = calculate_time_ranges(times)
  end

  private_class_method def self.calculate_time_ranges(times)
    if times == 'all day'
      [TimeOfDay.new(0, 0)..TimeOfDay.new(23, 30)]
    else
      breakdown_time_list(times)
    end
  end

  private_class_method def self.breakdown_time_list(time_list)
    time_range_descriptions = time_list.split('&').map(&:strip)
    time_range_descriptions.map { |desc| time_range(desc) }
  end

  private_class_method def self.time_range(time_range_description)
    start_time_desc, end_time_desc = time_range_description.split(DASH).map(&:strip)
    tod_start = time_of_day(start_time_desc,  false)
    tod_end   = time_of_day(end_time_desc,    true)
    Range.new(tod_start, tod_end)
  end

  private_class_method def self.time_of_day(time_of_day_description, rollback_30_minutes)
    hour_desc, minute_desc = time_of_day_description.split(':')
    tod = TimeOfDay.new(hour_desc.to_i, minute_desc.to_i)
    tod = TimeOfDay.add_hours_and_minutes(tod, 0, -30) if rollback_30_minutes
    tod
  end
end

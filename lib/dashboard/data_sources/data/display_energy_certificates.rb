# https://epc.opendatacommunities.org/docs/api/display
# - only works for state schools in England and Wales
# - schools sometimes split into multiple DECs - 1 for each building
# - range of dates for each school/building - typically annually
# - sometimes the kwh values aren't available, but can imply from co2
# - only bulidings > 250 m2 require DECs
# - they should be updated annually, but many aren't
require 'json'
require 'date'
require 'logger'
require 'faraday'

class DisplayEnergyCertificateJson
  def initialize(api_key = ENV['DECAPIKEY'])
    @api_key = api_key
    @headers = {
      'Authorization' => "Basic #{@api_key}",
      'Accept'        => 'application/json',
    }
  end

  def query_by_postcode(postcode)
    url_postcode = postcode.gsub(' ', '%20')
    url = "https://epc.opendatacommunities.org/api/v1/display/search?postcode=#{url_postcode}"
    raw_data(url)
  end

  def raw_data(url)
    uri = URI(url)
    connection = Faraday.new(uri, headers: @headers)
    response = connection.get
    response.body.empty? ? {} : JSON.parse(response.body)
  end
end

class DisplayEnergyCertificate
  class UnexpectedDataType < StandardError; end
  DEC_ELECTRICITY_CARBON_INTENSITY_KG_PER_KWH = 0.55
  DEC_GAS_CARBON_INTENSITY_KG_PER_KWH = 0.195

  def initialize(api_key = ENV['DECAPIKEY'])
    @api_key = api_key
  end

  # returns hash: [building_reference] = { latest  data }, { year2 data }
  def latest_data_by_building(postcode)
    all = data_all_dates(postcode)
    return {} if all.empty?

    all.transform_values{ |v| v.last }
  end

  # returns hash: [building_reference] = { latest  data }, { year2 data }
  def recent_data_by_building(postcode, recent_months: 9)
    data  = latest_data_by_building(postcode)
    return {} if data.empty?

    dates = data.values.map{ |d| d[:date]}.sort
    within_recent_months = dates.last - recent_months * 30
    data.select { |building, d| d[:date] >= within_recent_months }
  end

  # returns hash of latest data for each building, aggregated across all buildings
  def recent_aggregate_data(postcode)
    data = recent_data_by_building(postcode)
    return {} if data.empty?

    arrayed_data = merge_data_into_arrays(data)

    summed_data = sum_arrayed_data(arrayed_data)

    summed_data[:buildings] = arrayed_data.values.first.length

    summed_data
  end

  # returns hash: [building_reference] = [ { year1  data }, { year2 data } ]
  def data_all_dates(postcode)
    raw = DisplayEnergyCertificateJson.new(@api_key).query_by_postcode(postcode)
    return [] if raw.empty?
    data = raw['rows'].map do |year_of_data|
      extract_useful_dec_data_1_year(year_of_data)
    end

    data.sort_by!{ |d| d[:date] }

    by_building = {}
    data.each do |building_year|
      by_building[building_year[:building]] ||= []
      by_building[building_year[:building]].push(building_year)
    end
    by_building
  end

  private

  def extract_useful_dec_data_1_year(data)
    floor_area = data['total-floor-area'].to_f
    data = {
      building:             data['building-reference-number'],
      date:                 Date.parse(data['or-assessment-end-date']),
      address:              data['address'] || [data['address1'],data['address2'], data['address3']].compact.join(', '),
      name:                 data['address'].split(',').first,
      postcode:             data['postcode'],
      air_conditioning:     data['aircon-present'] == 'Yes',
      electricity_kwh:      data['annual-electrical-fuel-usage'].to_f * floor_area,
      electricity_co2:      data['electric-co2'].to_f * 1000.0,
      heating_kwh:          data['annual-thermal-fuel-usage'].to_f * floor_area,
      heating_co2:          data['heating-co2'].to_f * 1000.0,
      renewables_kwh:       data['renewables-electrical'].to_f * floor_area,
      renewable_heat_kwh:   data['renewables-fuel-thermal'].to_f * floor_area,
      renewables_types:     data['renewable-sources'],
      main_heating_fuel:    data['main-heating-fuel'],
      other_heating_fuel:   data['other-fuel'],
      floor_area:           floor_area,
      rating:               data['operational-rating-band'],
      environment:          data['building-environment'],
      local_authority_name: data['local-authority-label']
    }
    add_missing_kwh_data(data)
  end

  def add_missing_kwh_data(data)
    data[:calculated_electricity_kwh] =  if data[:electricity_kwh] == 0.0
      data[:electricity_co2] / DEC_ELECTRICITY_CARBON_INTENSITY_KG_PER_KWH
    else
      data[:electricity_kwh]
    end

    data[:calculated_heating_kwh] =  if data[:heating_kwh] == 0.0
      # may need enhancing for oil?
      data[:heating_co2] / DEC_GAS_CARBON_INTENSITY_KG_PER_KWH
    else
      data[:heating_kwh]
    end

    data
  end

  def merge_data_into_arrays(data)
    arrayed_data = {}
    data.values.map do |building|
      building.each do |type, value|
        arrayed_data[type] ||= []
        arrayed_data[type].push(value)
      end
    end
    arrayed_data
  end

  def sum_arrayed_data(arrayed_data)
    summed_data = arrayed_data.transform_values do |arr_data|
      if arr_data.first.is_a?(String)
        arr_data.uniq.join(' + ')
      elsif arr_data.first.is_a?(Float)
        arr_data.sum
      elsif arr_data.first.is_a?(Date)
        dates = arr_data.uniq
        dates.sort.last
      elsif [true, false].include?(arr_data.first)
        same = arr_data.all?{ |tf| tf == arr_data.first }
        same ? arr_data.first : :mixed
      else
        raise UnexpectedDataType, "Problem with #{arr_data.first.class.name}"
      end
    end
    summed_data
  end
end

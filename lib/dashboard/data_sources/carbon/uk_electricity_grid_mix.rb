# interfaces to https://carbon-intensity.github.io/api-definitions/#generation
# provides the live (&2018) UK electricity generation mix in percent with carbon information
require 'net/http'
require 'json'
require 'date'
require 'logger'

class UKElectricityGridMix
  include Logging

  GRIDCARBONINTENSITYFACTORSKGPERKWH = {
    # note the source strins are identical to the internet download so don't change!
    # http://gridwatch.co.uk/co2-emissions
    'biomass'     =>  0.020, # PH made up
    'coal'        =>  0.870,
    'imports'     =>  0.250,  # PH manually set to this figure, suspect is Netherlands (0.500) and French Nuclear(0.048)
    'gas'         =>  0.394,  # 0.487 figure doesnt look right to PH, is it beldned open and closed cycle? so used http://www.cs.ox.ac.uk/people/alex.rogers/gridcarbon/gridcarbon.pdf
    'nuclear'     =>  0.016,
    'other'       =>  0.250,  # PH manually set to this figure, suspect is Netherlands (0.500) and French Nuclear(0.048)
    'hydro'       =>  0.020,
    'solar'       =>  0.040,
    'wind'        =>  0.011
  }.freeze
  private_constant :GRIDCARBONINTENSITYFACTORSKGPERKWH

  ELECTRICITY_PERCENTS_IN_2018 = [
    [ 'gas',          0.39 ],
    [ 'nuclear',      0.19 ],
    [ 'wind',         0.17 ],
    [ 'biomass',      0.11 ],
    [ 'solar',        0.04 ],
    [ 'hydro',        0.02 ]
  ].freeze
  private_constant :ELECTRICITY_PERCENTS_IN_2018

  def carbon_intensity_table_live
    @carbon_intensity_table_live ||= generation_mix_live
  end

  def carbon_intensity_table_2018
    @carbon_intensity_table_live_2018 ||= generation_mix_2018
  end

  def net_carbon_intensity_live
    @net_carbon_intensity_live ||= calculate_net_intensity(carbon_intensity_table_live)
  end

  def net_carbon_intensity_2018
    @net_carbon_intensity_2018 ||= calculate_net_intensity(carbon_intensity_table_2018)
  end

  private

  def generation_mix_live
    enhance_data(download_percentage_electricity_by_source)
  end

  def generation_mix_2018
    enhance_data(ELECTRICITY_PERCENTS_IN_2018)
  end

  def calculate_net_intensity(by_percent_with_carbon)
    combined = by_percent_with_carbon.map { |_fuel_source, data| data[:intensity].nan? ? 0.0 : data[:intensity] * data[:percent] }
    combined.sum
  end

  def intensity(source)
    if GRIDCARBONINTENSITYFACTORSKGPERKWH.key?(source)
      GRIDCARBONINTENSITYFACTORSKGPERKWH[source]
    else
      Float::NAN
    end
  end

  def enhance_data(percentage_electricity_by_source)
    enhanced_data = {}

    percentage_electricity_by_source.each do |fuel_source, percent|
      enhanced_data[fuel_source] = {
         percent:             percent,
         intensity:           intensity(fuel_source),
         carbon_contribution: intensity(fuel_source) * percent
      }
    end

    total_intensity = calculate_net_intensity(enhanced_data)
    enhanced_data.each do |fuel_source, data|
      enhanced_data[fuel_source] = data.merge(carbon_percent: data[:carbon_contribution] / total_intensity)
    end
    enhanced_data
  end

  def download_percentage_electricity_by_source
    data = nil
    back_off_sleep_times = [0.1, 0.2, 0.3, 0.4]
    url = 'https://api.carbonintensity.org.uk/generation'

    # PH 3Feb2021 - seems to very occasionally be returning a nil;
    #             - not often enough to capture whether any server flags set
    #             - and to find a better way of dealing with this?
    #             - put response.tstaus logging in for now
    back_off_sleep_times.each do |time_seconds|
      response = Net::HTTP.get(URI(url))
      data = JSON.parse(response)
      break unless data.dig('data', 'generationmix').nil?
      sleep time_seconds
    end

    by_percent = []
    unless data.dig('data', 'generationmix').nil?
      by_percent = data['data']['generationmix'].map do |energy_source|
        [
          energy_source['fuel'],
          energy_source['perc'].to_f / 100.0
        ]
      end
    end
    by_percent
  end
end

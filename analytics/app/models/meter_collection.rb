# Meaning of this class has evolved over time, from a building, to data
# associated with a group of buildings (e.g. whole school or area of single meter)
#
# But now it largely holds the consumption, schedule data and analysis associated
# with a specific school.
class MeterCollection
  include Logging

  # These are things which will be populated
  attr_accessor :aggregated_heat_meters, :aggregated_electricity_meters,
                :electricity_simulation_meter, :storage_heater_meter,
                :holidays,
                :temperatures,
                :solar_irradiation,
                :solar_pv,
                :grid_carbon_intensity

  # For community use calculations
  attr_accessor :aggregated_electricity_meter_without_community_usage
  attr_accessor :aggregated_heat_meters_without_community_usage, :storage_heater_meter_without_community_usage,
                :community_disaggregator

  def initialize(school, holidays:, temperatures:, solar_pv:, grid_carbon_intensity:, solar_irradiation: nil,
                 pseudo_meter_attributes: {})
    @school = school
    @holidays = holidays
    @temperatures = temperatures
    @solar_pv = solar_pv
    @solar_irradiation = if solar_irradiation.nil?
                           SolarIrradianceFromPV.new('solar irradiance from pv',
                                                     solar_pv_data: solar_pv)
                         else
                           solar_irradiation
                         end
    @grid_carbon_intensity = grid_carbon_intensity

    @heat_meters = []
    @electricity_meters = []
    @storage_heater_meters = []
    @meter_identifier_lookup = {} # [mpan or mprn] => meter
    @aggregated_heat_meters = nil
    @aggregated_electricity_meters = nil
    @pseudo_meter_attributes = pseudo_meter_attributes
    @cached_open_time = TimeOfDay.new(7, 0) # for speed
    @cached_close_time = TimeOfDay.new(16, 30) # for speed
    @open_close_times = OpenCloseTimes.convert_frontend_times(@school.school_times, @school.community_use_times,
                                                              @holidays)
  end

  delegate :name, to: :@school

  delegate :postcode, to: :@school

  delegate :country, to: :@school

  delegate :funding_status, to: :@school

  delegate :urn, to: :@school

  delegate :area_name, to: :@school

  def default_energy_purchaser
    # use the area name for the moment
    @school.area_name
  end

  def merge_additional_pseudo_meter_attributes(pseudo_meter_attributes)
    @pseudo_meter_attributes = @pseudo_meter_attributes.deep_merge(pseudo_meter_attributes)
  end

  def delete_pseudo_meter_attribute(pseudo_meter_key, attribute_key)
    @pseudo_meter_attributes[pseudo_meter_key]&.delete(attribute_key)
  end

  def target_school?
    false
  end

  # Factory method to create a new meter in this meter collection,
  # copying values and data from an existing meter.
  #
  # @param Dashboard::Meter original the meter to copy
  # @param AmrData amr_data the amr data to populate the new meter
  # @param Symbol meter_type the type for the new meter
  # @param String identifier the identifier for the new meter
  # @param String name the name of the new meter
  # @param Symbol pseudo_meter_key a symbol indicates the name of pseudo meter attributes to copy into the new meter
  #
  # @return Dashboard::Meter the new meter
  def create_modified_copy_of_meter(original:, amr_data:, meter_type:, identifier:, name:, pseudo_meter_key: {})
    Dashboard::Meter.new(
      meter_collection: self,
      amr_data: amr_data,
      type: meter_type,
      identifier: identifier,
      name: name,
      floor_area: original.floor_area,
      number_of_pupils: original.number_of_pupils,
      solar_pv_installation: original.solar_pv_setup,
      meter_attributes: original.meter_attributes.merge(pseudo_meter_attributes(pseudo_meter_key))
    )
  end

  def aggregate_meter(fuel_type)
    case fuel_type
    when :electricity
      aggregated_electricity_meters
    when :gas
      aggregated_heat_meters
    when :storage_heater, :storage_heaters
      storage_heater_meter
    when :solar_pv
      aggregated_electricity_meters.sub_meters[:generation]
    end
  end

  def set_aggregate_meter(fuel_type, meter)
    case fuel_type
    when :electricity
      @aggregated_electricity_meters = meter
    when :gas
      @aggregated_heat_meters = meter
    when :storage_heater, :storage_heaters
      @storage_heater_meter = meter
    when :solar_pv
      @aggregated_electricity_meters.sub_meters[:generation] = meter
    end
  end

  def set_aggregate_meter_non_community_use_meter(fuel_type, meter)
    case fuel_type
    when :electricity
      @aggregated_electricity_meter_without_community_usage = meter
    when :gas
      @aggregated_heat_meters_without_community_usage = meter
    when :storage_heater, :storage_heaters
      @storage_heater_meter_without_community_usage = meter
    end
  end

  def update_electricity_meters(electricity_meter_list)
    @electricity_meters = electricity_meter_list
  end

  def aggregated_unaltered_electricity_meters
    aggregated_electricity_meters.sub_meters.fetch(:mains_consume, aggregated_electricity_meters)
  end

  # attr_reader/@floor_area is set by the front end
  # if there are relevant pseudo meter attributes
  # override it with a calculated value
  def floor_area(start_date = nil, end_date = nil)
    calculate_floor_area_number_of_pupils
    @calculated_floor_area_pupil_numbers.floor_area(start_date, end_date)
  end

  def number_of_pupils(start_date = nil, end_date = nil)
    calculate_floor_area_number_of_pupils
    @calculated_floor_area_pupil_numbers.number_of_pupils(start_date, end_date)
  end

  def calculate_floor_area_number_of_pupils
    @calculated_floor_area_pupil_numbers ||= FloorAreaPupilNumbers.new(@school.floor_area, @school.number_of_pupils,
                                                                       pseudo_meter_attributes(:school_level_data))
  end

  def earliest_meter_date
    all_meters.map { |meter| meter.amr_data.start_date }.min
  end

  def last_combined_meter_date
    all_aggregate_meters.map { |meter| meter.amr_data.end_date }.min
  end

  def inspect
    "Meter Collection (name: '#{@school.name}', object_id: #{format('0x00%x', object_id << 1)})"
  end

  def to_s
    'Meter Collection:' + name + ':' + all_meters.join(';')
  end

  def meter?(identifier, search_sub_meters = false)
    identifier = identifier.to_s # ids coulld be integer or string
    return @meter_identifier_lookup[identifier] if @meter_identifier_lookup.key?(identifier)

    meter = search_meter_list_for_identifier(all_meters, identifier)
    unless meter.nil?
      @meter_identifier_lookup[identifier] = meter
      return meter
    end

    if search_sub_meters
      all_meters.each do |meter|
        sub_meter = search_meter_list_for_identifier(meter.all_sub_meters, identifier)
        unless sub_meter.nil?
          @meter_identifier_lookup[identifier] = sub_meter
          return sub_meter
        end
      end
    end

    @meter_identifier_lookup[identifier] = nil
    nil
  end

  delegate :latitude, to: :@school

  delegate :longitude, to: :@school

  private def search_meter_list_for_identifier(meter_list, identifier)
    return nil if identifier.nil?

    meter_list.each do |meter|
      next if meter.id.nil?
      return meter if meter.id.to_s == identifier.to_s
    end
    nil
  end

  def all_meters(ensure_unique: true, include_sub_meters: true)
    meter_list = [
      @heat_meters,
      @electricity_meters,
      @storage_heater_meters,
      @storage_heater_meter,
      @aggregated_heat_meters,
      @aggregated_electricity_meters
    ].compact.flatten

    meter_list += meter_list.map { |m| m.sub_meters.values.compact } if include_sub_meters

    meter_list.flatten!

    meter_list.uniq! { |meter| meter.mpan_mprn } if ensure_unique

    meter_list
  end

  # TODO: remove reference in front-end
  def real_meters2
    real_meters
  end

  # some meters are 'artificial' e.g. split off storage meters and re aggregated solar PV meters
  #
  # This version of the code avoids checking synthetic_mpan_mprn?
  # which can pickup real meters coming in from 3rd party systems like
  # Orsis where the MPAN is made up; used to test whether this approach works
  def real_meters
    meter_list = [
      @heat_meters,
      @electricity_meters,
      @storage_heater_meters
    ].compact.flatten

    meters = meter_list.map { |m| m.sub_meters.fetch(:mains_consume, m) }

    meters.uniq { |meter| meter.mpxn }
  end

  def underlying_meters(fuel_type)
    case fuel_type
    when :electricity
      @electricity_meters
    when :gas
      @heat_meters
    when :storage_heater
      @storage_heater_meters
    else
      []
    end
  end

  def report_group
    if !aggregated_heat_meters.nil?
      if aggregated_electricity_meters.nil?
        :gas_only
      else
        solar_pv_panels? ? :electric_and_gas_and_solar_pv : :electric_and_gas
      end
    elsif solar_pv_panels?
      :electric_and_solar_pv
    elsif storage_heaters?
      :electric_and_storage_heaters
    else
      :electric_only
    end
  end

  def all_heat_meters
    all_meters.select { |meter| meter.heat_meter? }
  end

  def all_electricity_meters
    all_meters.select { |meter| meter.electricity_meter? }
  end

  def gas_only?
    all_meters.select { |meter| meter.electricity_meter? }.empty?
  end

  def non_heating_only?
    all_heat_meters.all? { |meter| meter.non_heating_only? }
  end

  def heating_only?
    all_heat_meters.all? { |meter| meter.heating_only? }
  end

  def electricity?
    !aggregated_electricity_meters.nil?
  end

  def gas?
    !aggregated_heat_meters.nil?
  end

  def storage_heaters?
    @has_storage_heaters ||= all_meters.any? { |meter| meter.storage_heater? }
  end

  def solar_pv_panels?
    @solar_pv_panels ||= all_meters.any? { |meter| meter.solar_pv_panels? }
  end

  def sheffield_simulated_solar_pv_panels?
    @sheffield_simulated_solar_pv_panels ||= all_meters.any? { |meter| meter.sheffield_simulated_solar_pv_panels? }
  end

  def solar_pv_real_metering?
    @solar_pv_real_metering ||= all_meters.any? { |meter| meter.solar_pv_real_metering? }
  end

  def solar_pv_and_or_storage_heaters?
    storage_heaters? || solar_pv_panels?
  end

  def all_aggregate_meters
    [
      electricity? ? aggregated_electricity_meters : nil,
      gas? ? aggregated_heat_meters : nil,
      storage_heaters? ? storage_heater_meter : nil
    ].compact
  end

  delegate :community_usage?, to: :open_close_times

  def fuel_types(exclude_storage_heaters = true, exclude_solar_pv = true)
    types = []
    types.push(:electricity)      if electricity?
    types.push(:gas)              if gas?
    types.push(:storage_heaters)  if storage_heaters? && !exclude_storage_heaters
    types.push(:solar_pv)         if solar_pv_panels? && !exclude_solar_pv
    types
  end

  def school_type
    @school.school_type.to_sym
  end

  def energysparks_start_date
    @school.activation_date || @school.creation_date
  end

  delegate :activation_date, to: :@school

  delegate :creation_date, to: :@school

  def add_heat_meter(meter)
    @heat_meters.push(meter)
    @meter_identifier_lookup[meter.id] = meter
  end

  def add_electricity_meter(meter)
    @electricity_meters.push(meter)
    @meter_identifier_lookup[meter.id] = meter
  end

  def add_aggregate_heat_meter(meter)
    @aggregated_heat_meters = meter
    @meter_identifier_lookup[meter.id] = meter
  end

  def add_aggregate_electricity_meter(meter)
    @aggregated_electricity_meters = meter
    @meter_identifier_lookup[meter.id] = meter
  end

  def open_time
    @cached_open_time
  end

  def close_time
    @cached_close_time
  end

  attr_reader :heat_meters, :electricity_meters, :storage_heater_meters, :school, :model_cache, :open_close_times

  # def target_school(type = :day)
  #   @target_school ||= {}
  #   @target_school[type] ||= TargetSchool.new(self, type)
  # end

  def benchmark_school(benchmark_type = :benchmark)
    @benchmark_school ||= {}
    @benchmark_school[benchmark_type] ||= BenchmarkSchool.new(self, benchmark_type: benchmark_type)
  end

  def reset_target_school_for_testing(type = :day)
    @target_school.delete(type) unless @target_school.nil?
  end

  def pseudo_meter_attributes(type)
    @pseudo_meter_attributes.fetch(type) { {} }
  end

  def pseudo_meter_attributes_private
    @pseudo_meter_attributes
  end

  def meter_attribute_types
    @pseudo_meter_attributes.keys
  end

  # Notify meter collection that aggregation process is over.
  # Allows for any post aggregation clean-up to be carried out.
  def notify_aggregation_complete!
    clean_up_schedule_data!

    # Set flags on each meter to indicate aggregation process has
    # been completed.
    #
    # allows parameterised carbon/cost objects to cache data post
    # aggregation, reducing memory footprint in front end cache prior to this
    # while maintaining charting performance once out of cache
    all_meters(ensure_unique: false).each do |meter|
      meter.amr_data.open_close_breakdown = CommunityUseBreakdown.new(meter, @open_close_times)
      meter.amr_data.set_post_aggregation_state
    end
  end

  # Prints a description of the current metering setup for the meter collection.
  #
  # Dumps the list of aggregate meters for the whole school along with their sub meters,
  # then the list of individual electricity and gas meters with their sub meters.
  #
  # If a category of meter or submeter isn't in the collection, then its skipped.
  #
  # Uses +Meter.inspect+ to print meters to help clarify both the meter/submeter configuration
  # and the object ids as meters can effectively be cloned during aggregation (same type, date ranges
  # mpan, etc)
  #
  # Intended to help with debugging any aggregation issues or just reviewing state of the
  # collection.
  def print_meter_setup
    puts 'Aggregated Data'
    puts '-' * 35
    %i[aggregated_electricity_meters aggregated_heat_meters storage_heater_meter].each do |method|
      meter = send(method)
      next unless meter.present?

      puts "#{format('%-35s', method)} #{meter.inspect}"
      meter.sub_meters.each do |key, sub_meter|
        puts "  - #{format('%-31s', key)} #{sub_meter.inspect}"
      end
    end
    %i[electricity heat storage_heater].each do |method|
      meters = send("#{method}_meters")
      next unless meters.any?

      puts "\n#{method.to_s.humanize} Meters"
      puts '-' * 35
      meters.each.with_index(1) do |meter, index|
        puts "  #{format('%-33s', index)} #{meter.inspect}"
        meter.sub_meters.each do |key, sub_meter|
          puts "    - #{format('%-29s', key)} #{sub_meter.inspect}"
        end
      end
    end
    puts '-' * 35
  end

  private

  TARGET_TEMPERATURE_DAYS_EITHER_SIDE = 4
  private_constant :TARGET_TEMPERATURE_DAYS_EITHER_SIDE

  # Clip the schedule data to the earliest date that we need for charting or
  # subsequent analysis.
  def clean_up_schedule_data!
    earliest_date = earliest_meter_date
    return if earliest_date.nil?

    grid_carbon_intensity.set_start_date(earliest_date)

    # we need a bit more temperature and solar data for calculating targets and annual estimates,
    # so adjust date by one year for solar and
    earliest_date -= (365 + TARGET_TEMPERATURE_DAYS_EITHER_SIDE)
    solar_pv.set_start_date(earliest_date)
    solar_irradiation.set_start_date(earliest_date)
    temperatures.set_start_date(earliest_date)
  end
end

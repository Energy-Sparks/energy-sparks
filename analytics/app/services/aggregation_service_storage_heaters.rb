# frozen_string_literal: true

# Electricity meters with storage heaters are flagged by the presence of a
# storage heater meter attribute on the meter.
#
# Where the meter also have appliance comsumption
# synthetically split the meter into 2 meters: 1. storage heaters 2. the rest/appliances
#
# where there are multiple electricity meters, the sh meter, the appliance meter and the original meter
# are then aggregated seperately, so there are aggregate versions of each
#
class StorageHeaterMap < RestrictedKeyHash
  def self.unique_keys
    %i[original storage_heater ex_storage_heater]
  end
end

class AggregateDataServiceStorageHeaters
  include Logging
  include AggregationMixin

  attr_reader :meter_collection

  def initialize(meter_collection)
    @meter_collection   = meter_collection
    @electricity_meters = @meter_collection.electricity_meters
  end

  # Disaggregate any storage heater use from other electricity consumption, creating new meters to reflect each type
  # of usage.
  #
  # Will end up reassigning the aggregate electricity meter to a new meter, as well as setting the aggregate storage
  # heater meter
  def disaggregate
    logger.debug { '=' * 100 }
    logger.debug { "Disaggregating storage heater meters for #{@meter_collection.name}: #{@electricity_meters.length} electricity meters" }

    bm = Benchmark.realtime do
      # Separate out the storage heater consumption from other usage across all electricity meters
      # Returns an array of StorageHeaterMap instances that refer to all the original and new meters.
      #
      # As a side-effect the @electricity_meters array has been updated to replace any meter with
      # storage heaters with a newly created meter that has the non storage heater usage
      reworked_meter_maps = disaggregate_meters

      # Set the costs, co2 emissions schedules on every meter
      # TODO: probably unnecessary to do this for the :original meters, as this was done in the previous
      # stage of aggregation. Possibly optimisation?
      calculate_meters_carbon_emissions_and_costs(reworked_meter_maps)

      aggregate = if @electricity_meters.length > 1
                    aggregate_meters(reworked_meter_maps)
                  else
                    reworked_meter_maps[0]
                  end

      # Assign the aggregate electricity and storage heater meters
      assign_aggregate(aggregate)
    end

    summarise_aggregated_meter
    summarise_component_meters

    logger.debug { "Disaggregation of storage heater meters for #{@meter_collection.name} complete in #{bm.round(3)} seconds" }
    logger.debug { '=' * 100 }
  end

  private

  # Extract the storage heater usage from the other electricity usage for all of the
  # electricity meters
  #
  # Returns an array of StorageHeaterMap instances, one per electricity meter.
  def disaggregate_meters
    @electricity_meters.map.with_index do |electricity_meter, i|
      if electricity_meter.storage_heater?
        # split out the meter, returning map
        map = disaggregate_storage_heat_meter(electricity_meter)
        # reorganise the sub meters, returning the +ex_storage_heater+ meter
        # which then replaces the original electricity meter in the array
        @electricity_meters[i] = reassign_meters(map)
      else
        # leaves the original meter unchanged, create a default map
        map = StorageHeaterMap.new
        map[:original]          = electricity_meter
        map[:ex_storage_heater] = electricity_meter
      end
      map
    end
  end

  # Assign the aggregate electricity and aggregate storage heater meters after first
  # updating the sub_meter relationships
  def assign_aggregate(meter_map)
    reassign_meters(meter_map)
    @meter_collection.aggregated_electricity_meters = meter_map[:ex_storage_heater]
    @meter_collection.storage_heater_meter = meter_map[:storage_heater]
  end

  # Turns a single electricity meter, with configured storage heaters into two new meters, one with
  # just the storage heater consumption and the other with the rest
  #
  # The new meters will have a synthetic map and their name will be suffixed with an indication of whether
  # they are the storage heater ("... Storage heater disaggregated storage heter") or electricity usage
  # ("...Storage heater disaggregated electricity").
  #
  # Returns an StorageHeaterMap has has the :original, :storage_heater and :ex_storage_heater meters.
  def disaggregate_storage_heat_meter(meter)
    map = StorageHeaterMap.new
    map[:original] = meter

    # Create new AMRData instances one for the storage heater use and one for the rest of the consumption
    electric_only_amr, storage_heater_amr = meter.storage_heater_setup.disaggregate_amr_data(meter.amr_data, meter.mpan_mprn)

    map[:storage_heater]    = create_meter(meter, storage_heater_amr, :storage_heater_disaggregated_storage_heater, :storage_heater)
    map[:ex_storage_heater] = create_meter(meter, electric_only_amr,  :storage_heater_disaggregated_electricity)
    map
  end

  def summarise_aggregated_meter
    logger.debug { 'Aggregated Meter Setup' }
    logger.debug { "    appliance: #{aggregate_meter_description(@meter_collection.aggregated_electricity_meters)}" }
    logger.debug { "    storage:   #{aggregate_meter_description(@meter_collection.storage_heater_meter)}" }
    logger.debug { "    original:  #{aggregate_meter_description(@meter_collection.aggregated_electricity_meters.sub_meters[:mains_consume])}" }
  end

  def aggregate_meter_description(meter)
    format('%60.60s: %9.0f kWh', meter.to_s, meter.amr_data.total)
  end

  def summarise_component_meters
    logger.debug('Component Meter Setup')
    @meter_collection.electricity_meters.each.with_index do |meter, i|
      logger.debug { "    Meter #{i}" }
      logger.debug { format('        %-18.18s %s', 'ex storage heater', meter_description(meter)) }
      logger.debug { format('        %-18.18s %s', 'original',          meter_description(meter.sub_meters[:mains_consume])) }
      logger.debug { format('        %-18.18s %s', 'storage heaters',   meter_description(meter.sub_meters[:storage_heaters])) }
    end
  end

  # Reworks the meter associations in the provided StorageHeaterMap
  #
  # The sub_meters from the :original meter are added to the new :ex_storage_heater
  # meter. So this has the relationships to the solar meters, if any
  #
  # The :original and :storage_heater meter are added as additional sub_meters. The
  # original being the :mains_consume.
  def reassign_meters(map)
    # Copy the solar sub meters from the original electricity meters to be sub meters
    # of the new version that doesn't include storage heater usage
    map[:ex_storage_heater].sub_meters.merge!(map[:original].sub_meters)

    # By default the mains consumption meter for the new electricity meter should be
    # the original meter. However if the original meter was created during the solar
    # aggregation, then its AMR data will correspond to main_consume + self_consume.
    # In this case we should use its original mains consumption meter and not the
    # meter created in the solar aggregation step
    map[:ex_storage_heater].sub_meters[:mains_consume] = if map[:original].sub_meters.key?(:self_consume) && map[:original].sub_meters.key?(:mains_consume)
                                                           map[:original].sub_meters[:mains_consume]
                                                         else
                                                           map[:original]
                                                         end
    map[:ex_storage_heater].sub_meters[:storage_heaters] = map[:storage_heater]
    map[:ex_storage_heater]
  end

  # Takes an array of StorageHeaterMaps and returns a new StorageHeaterMap which provides references to a
  # newly created aggregate meter.
  #
  #
  def aggregate_meters(meter_maps)
    # Rework the provided array of maps, so we have a single map
    # having an array of meters
    aggregate_map = StorageHeaterMap.new
    meter_maps.each do |meter_map|
      meter_map.each do |type, meter|
        next if meter.nil?

        aggregate_map[type] ||= []
        aggregate_map[type].push(meter)
      end
    end

    # Combine the AMRData for every meter type in the map
    # E.g. add up all :original, all :storage_heater and all :ex_storage_heater usage
    aggregated_amr_data = aggregate_map.transform_values do |meters|
      aggregate_amr_data(meters, :electricity)
    end

    # New map for the aggregated meter
    aggregated_meter_map = StorageHeaterMap.new
    type_map = {
      storage_heater: :storage_heater_disaggregated_storage_heater,
      ex_storage_heater: :storage_heater_disaggregated_electricity,
      original: :aggregated_electricity
    }
    aggregated_amr_data.each do |type, amr_data|
      fuel_type = type == :storage_heater ? :storage_heater : :electricity
      # Create new meters for the storage_heater, ex_storage_heater and original, using the
      # first meter of that type as a template, and the sum of the AMRData for that type
      aggregated_meter_map[type] = create_meter(aggregate_map[type][0], amr_data, type_map[type], fuel_type)
    end

    # Set costs/co2 schedule for each of the new meters
    calculate_carbon_emissions_and_costs(aggregated_meter_map)

    aggregated_meter_map
  end

  def meter_description(meter)
    meter.nil? ? '' : format('%14.14s %.0f kWh', meter.mpxn, meter.amr_data.total)
  end

  def create_meter(meter, amr_data, meter_type, fuel_type = :electricity)
    identifier = if meter_type == :aggregated_electricity
                   Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(@meter_collection.urn, meter_type)
                 else
                   Dashboard::Meter.synthetic_mpan_mprn(meter.id, meter_type)
                 end

    @meter_collection.create_modified_copy_of_meter(
      original: meter,
      amr_data: amr_data,
      meter_type: fuel_type,
      identifier: identifier,
      name: "#{meter.name} #{meter_type.to_s.humanize}",
      pseudo_meter_key: meter_type
    )
  end

  def calculate_meters_carbon_emissions_and_costs(maps)
    maps.each do |map|
      calculate_carbon_emissions_and_costs(map)
    end
  end

  def calculate_carbon_emissions_and_costs(map)
    map.each_value do |meter|
      next if meter.nil?

      calculate_meter_carbon_emissions_and_costs(meter, :electricity)
    end
  end
end

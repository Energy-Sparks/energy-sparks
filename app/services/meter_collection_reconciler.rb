# frozen_string_literal: true

# Compares 2 meter collections: primarily for testing of feeds or meter validations
# has various levels of verbosity/detail
# bespoke implementaton, did review HashDiff gem, but not suitable/specific enough
#
class MeterCollectionReconciler
  include Logging

  attr_reader :deleted_meters, :inserted_meters, :matching_meters

  def initialize(existing_meter_collection, new_meter_collection)
    @existing_meter_collection = existing_meter_collection
    @existing_meter_list = id_to_meter_map(existing_meter_collection)

    @new_meter_collection = new_meter_collection
    @new_meter_list = id_to_meter_map(new_meter_collection)
    @meter_reading_comparisons = {}
  end

  def compare
    logger.info "Comparing meters for #{@new_meter_collection.name}"
    @deleted_meters, @inserted_meters, @matching_meters = compare_meters

    matching_meters.each do |meter1, meter2|
      meter_reconciler = MeterReconciler.new(meter1, meter2)
      meter_reconciler.compare_meter_readings
      @meter_reading_comparisons[meter1.id] = meter_reconciler
    end
  end

  def meters_with_percent_change_above(percent)
    @meter_reading_comparisons.select { |_id, reconciler| reconciler.percent > percent }
  end

  def print_comparison(verbosity = 0)
    if verbosity >= 0
      logger.info "Comparing meters for meter_collection #{@existing_meter_collection.name}"
      logger.info "  #{deleted_meters.length} deleted meters #{inserted_meters.length} new meters from #{matching_meters.length} matching"
    end
    return unless verbosity >= 1

    @meter_reading_comparisons.each_value do |meter_readings_comparison|
      meter_readings_comparison.print_comparison(verbosity)
    end
  end

  private

  def id_to_meter_map(meter_collection)
    meter_collection.all_meters.map { |meter| [meter.id, meter] }.to_h
  end

  def compare_meters
    inserted = @existing_meter_list.reject { |id, _meter| @new_meter_list.key?(id) }
    deleted = @new_meter_list.reject { |id, _meter| @existing_meter_list.key?(id) }
    same_ids = @new_meter_list.keys.select { |id| @existing_meter_list.key?(id) }
    same = same_ids.map { |id| [@existing_meter_list[id], @new_meter_list[id]] } # pair of meters
    [deleted.values, inserted.values, same]
  end
end

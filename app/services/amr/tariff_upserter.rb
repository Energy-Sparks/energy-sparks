module Amr
  class TariffUpserter
    def initialize(array_of_price_hashes, array_of_standing_charge_hashes, import_log)
      @array_of_price_hashes = array_of_price_hashes
      @array_of_standing_charge_hashes = array_of_standing_charge_hashes
      @import_log = import_log
    end

    def perform
      ActiveRecord::Base.transaction do
        upsert_prices
        upsert_standing_charges
      end
    end

    def upsert_prices
      records_count_before = N3rgyTariffPrice.count
      data_for_upsert = add_import_log_id_and_dates_to_hash(@array_of_price_hashes)

      result = N3rgyTariffPrice.upsert_all(data_for_upsert, unique_by: [:meter_id, :tariff_date])

      inserted_count = N3rgyTariffPrice.count - records_count_before
      updated_count = result.rows.flatten.size - inserted_count

      @import_log.update(prices_imported: inserted_count, prices_updated: updated_count)

      Rails.logger.info "Updated #{updated_count} Inserted #{inserted_count}"
    end

    def upsert_standing_charges
      records_count_before = N3rgyTariffStandingCharge.count
      data_for_upsert = add_import_log_id_and_dates_to_hash(@array_of_standing_charge_hashes)

      result = N3rgyTariffStandingCharge.upsert_all(data_for_upsert, unique_by: [:meter_id, :start_date])

      inserted_count = N3rgyTariffStandingCharge.count - records_count_before
      updated_count = result.rows.flatten.size - inserted_count

      @import_log.update(standing_charges_imported: inserted_count, standing_charges_updated: updated_count)

      Rails.logger.info "Updated #{updated_count} Inserted #{inserted_count}"
    end

    private

    def add_import_log_id_and_dates_to_hash(arr)
      created_at = DateTime.now.utc
      updated_at = DateTime.now.utc
      arr.each do |reading|
        reading[:n3rgy_tariff_import_log_id] = @import_log.id
        reading[:created_at] = created_at
        reading[:updated_at] = updated_at
      end
      arr
    end
  end
end

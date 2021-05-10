module Amr
  class TariffUpserter
    def initialize(array_of_price_hashes, array_of_standing_charge_hashes, tariff_import_log)
      @array_of_price_hashes = array_of_price_hashes
      @array_of_standing_charge_hashes = array_of_standing_charge_hashes
      @tariff_import_log = tariff_import_log
    end

    def perform
      upsert_prices
      upsert_standing_charges
    end

    def upsert_prices
      records_count_before = TariffPrice.count
      data_for_upsert = add_import_log_id_and_dates_to_hash(@array_of_price_hashes)

      updated_count = 0
      inserted_count = 0

      unless data_for_upsert.empty?
        result = TariffPrice.upsert_all(data_for_upsert, unique_by: [:meter_id, :tariff_date])
        inserted_count = TariffPrice.count - records_count_before
        updated_count = result.rows.flatten.size - inserted_count
      end

      @tariff_import_log.update(prices_imported: inserted_count, prices_updated: updated_count)

      Rails.logger.info "Updated #{updated_count} Inserted #{inserted_count}"
    end

    def upsert_standing_charges
      records_count_before = TariffStandingCharge.count
      data_for_upsert = add_import_log_id_and_dates_to_hash(@array_of_standing_charge_hashes)

      updated_count = 0
      inserted_count = 0

      unless data_for_upsert.empty?
        result = TariffStandingCharge.upsert_all(data_for_upsert, unique_by: [:meter_id, :start_date])
        inserted_count = TariffStandingCharge.count - records_count_before
        updated_count = result.rows.flatten.size - inserted_count
      end

      @tariff_import_log.update(standing_charges_imported: inserted_count, standing_charges_updated: updated_count)

      Rails.logger.info "Updated #{updated_count} Inserted #{inserted_count}"
    end

    private

    def add_import_log_id_and_dates_to_hash(arr)
      created_at = DateTime.now.utc
      updated_at = DateTime.now.utc
      arr.each do |reading|
        reading[:tariff_import_log_id] = @tariff_import_log.id
        reading[:created_at] = created_at
        reading[:updated_at] = updated_at
      end
      arr
    end
  end
end

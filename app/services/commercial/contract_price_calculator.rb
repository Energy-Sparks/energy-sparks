# frozen_string_literal: true

module Commercial
  class Commercial::ContractPriceCalculator
    def initialize(contract)
      @contract = contract
      @product  = contract.product
    end

    def per_school
      @per_school ||= calculate_per_school
    end

    def totals
      rows = per_school

      {
        base_price: rows.values.sum { |r| r[:base_price] },
        metering_fee: rows.values.sum { |r| r[:metering_fee] },
        private_account_fee: rows.values.sum { |r| r[:private_account_fee] },
        total: rows.values.sum { |r| r[:total] }
      }
    end

    private

    def calculate_per_school
      rows = schools_scope.select(calculate_price_sql)

      rows.to_h { |row| [row.school_id, row_to_price_hash(row)] }
    end

    def meter_counts
      Meter
        .where(pseudo: false, meter_type: Meter::MAIN_METER_TYPES, active: true)
        .group(:school_id)
        .select('school_id, COUNT(*) AS meter_count')
    end

    def schools_scope
      @contract.schools
               .joins(<<~SQL.squish)
                 INNER JOIN commercial_licences licences
                   ON licences.school_id = schools.id
                   AND licences.contract_id = #{@contract.id}
               SQL
               .joins(<<~SQL.squish)
                 LEFT JOIN (#{meter_counts.to_sql}) meters
                   ON meters.school_id = schools.id
               SQL
    end

    def row_to_price_hash(row)
      Price.new(
        base_price: row.base_price.to_f,
        metering_fee: row.metering_fee.to_f,
        private_account_fee: row.private_account_fee.to_f
      ).then do |price|
        {
          id: row.school_id,
          name: row.school_name,
          price: price
        }
      end
    end

    # rubocop:disable Metrics/MethodLength
    def calculate_price_sql
      size_threshold_sql       = sql_number(@product.size_threshold)
      small_school_price_sql   = sql_number(@product.small_school_price)
      large_school_price_sql   = sql_number(@product.large_school_price)
      metering_fee_sql         = sql_number(@product.metering_fee)
      private_account_fee_sql  = sql_number(@product.private_account_fee)
      agreed_school_price_sql  = sql_number(@contract.agreed_school_price)

      <<~SQL.squish
        schools.id AS school_id,
        schools.name AS school_name,

        CASE
          WHEN licences.school_specific_price IS NOT NULL
            THEN licences.school_specific_price
          WHEN #{agreed_school_price_sql} IS NOT NULL
            THEN #{agreed_school_price_sql}
          WHEN schools.number_of_pupils <= #{size_threshold_sql}
            THEN #{small_school_price_sql}
          ELSE #{large_school_price_sql}
        END AS base_price,

        CASE
          WHEN licences.school_specific_price = 0
            THEN 0
          WHEN COALESCE(meters.meter_count, 0) > 5
            THEN #{metering_fee_sql} * (meters.meter_count - 5)
          ELSE 0
        END AS metering_fee,

        CASE
          WHEN licences.school_specific_price = 0
            THEN 0
          WHEN schools.data_sharing != 'public'
            THEN #{private_account_fee_sql}
          ELSE 0
        END AS private_account_fee
      SQL
    end
    # rubocop:enable Metrics/MethodLength

    def sql_number(value)
      value.nil? ? 'NULL' : value
    end
  end
end

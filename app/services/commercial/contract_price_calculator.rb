# frozen_string_literal: true

module Commercial
  # rubocop:disable Metrics/ClassLength
  class ContractPriceCalculator
    def initialize(contract)
      @contract = contract
      @product  = contract.product
    end

    def per_school
      @per_school ||= calculate_per_school
    end

    def totals
      rows = per_school

      @totals ||= Price.new(
        base_price: rows.values.sum { |r| r[:price].base_price },
        metering_fee: rows.values.sum { |r| r[:price].metering_fee },
        private_account_fee: rows.values.sum { |r| r[:price].private_account_fee }
      )
    end

    private

    def calculate_per_school
      rows = schools_scope.select(calculate_price_sql)
      rows.to_h { |row| [row.school_id, row_to_price_hash(row)] }
    end

    def row_to_price_hash(row)
      {
        id: row.school_id,
        licence_id: row.licence_id,
        name: row.school_name,
        price: calculate_price(row)
      }
    end

    def calculate_price(row)
      multiplier = length_multiplier * prorata_multiplier(licence_start_date, licence_end_date)
      Price.new(
        base_price: row.base_price.to_f * multiplier,
        metering_fee: row.metering_fee.to_f * multiplier,
        private_account_fee: row.private_account_fee.to_f * multiplier
      )
    end

    def length_multiplier
      @contract.licence_period_days.to_f / 365.0
    end

    def prorata_multiplier(licence_start_date, licence_end_date)
      return 1.0 if @contract.invoice_terms == 'full'

      licence_days = (licence_end_date - licence_start_date).to_i
      full_days = @contract.licence_period_days.to_f

      licence_days.to_f / full_days
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
               .order('schools.name')
    end

    def meter_counts
      Meter.main_meter_counts_by_school.select('school_id, COUNT(*) AS meter_count')
    end

    def calculate_price_sql # rubocop:disable Metrics/MethodLength
      size_threshold_sql       = sql_number(@product.size_threshold)
      small_school_price_sql   = sql_number(@product.small_school_price)
      large_school_price_sql   = sql_number(@product.large_school_price)
      metering_fee_sql         = sql_number(@product.metering_fee)
      private_account_fee_sql  = sql_number(@product.private_account_fee)
      agreed_school_price_sql  = sql_number(@contract.agreed_school_price)

      <<~SQL.squish
        schools.id AS school_id,
        schools.name AS school_name,
        licences.id AS licence_id,
        licences.start_date AS licence_start_date,
        licences.end_date AS licence_end_date,

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

    def sql_number(value)
      value.nil? ? 'NULL' : value
    end
  end
  # rubocop:enable Metrics/ClassLength
end

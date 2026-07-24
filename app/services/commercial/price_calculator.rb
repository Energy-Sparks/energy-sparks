# frozen_string_literal: true

module Commercial
  class PriceCalculator
    METER_LIMIT = 5 # Above this number of meters we charge extra fee

    # Calculates a price for a single school based on the pricing rules for a specific product
    # and the characteristics of the school.
    #
    # Used for producing an estimated price for a school that has not yet joined Energy Sparks so
    # there is not yet a school record.
    #
    # Does not produce pro-rata pricing at present, estimates are assumed to be for the full
    # contracted period
    def calculate(number_of_pupils:, number_of_meters:, product: nil, contract: nil, private_account: false)
      raise unless product || contract

      contracted_product = contract&.product || product
      base_price = base_price(product: contracted_product, contract:, number_of_pupils:)

      return Price::FREE if base_price == 0.0

      length_multiplier = contract_length_multiplier(contract)

      Price.new(
        base_price: base_price * length_multiplier,
        metering_fee: metering_fee(product: contracted_product, number_of_meters:) * length_multiplier,
        private_account_fee: private_account_fee(product: contracted_product, private_account:) * length_multiplier
      )
    end

    private

    def base_price(product:, number_of_pupils:, contract: nil)
      return contract.agreed_school_price if contract&.agreed_school_price

      if number_of_pupils <= product.size_threshold
        product.small_school_price
      else
        product.large_school_price
      end
    end

    def metering_fee(product:, number_of_meters:)
      return 0.0 unless number_of_meters > METER_LIMIT

      product.metering_fee * (number_of_meters - METER_LIMIT)
    end

    def private_account_fee(product:, private_account: false)
      return 0.0 unless private_account

      product.private_account_fee
    end

    def contract_length_multiplier(contract)
      return 1.0 unless contract
      return contract.licence_years if contract.custom?

      Commercial::Licence.licence_period_days(
        contract.start_date, contract.end_date
      ).to_f / 365.0
    end
  end
end

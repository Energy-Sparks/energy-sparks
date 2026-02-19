module Commercial
  class PriceCalculator
    # Calculates a price for a single school based on the pricing rules for a specific product
    # and the characteristics of the school.
    #
    # Used for producing an estimated price for a school that has not yet joined Energy Sparks so
    # there is not yet a school record.
    def calculate(number_of_pupils:, number_of_meters:, product: nil, contract: nil, private_account: false)
      raise unless product || contract
      contracted_product = contract&.product || product
      return base_price(product:, contract:, number_of_pupils:) +
             metering_fee(product: contracted_product, number_of_meters:) +
             private_account_fee(product: contracted_product, private_account:)
    end

    # Calculates a price for a school if added to a current contract. Does not
    # check for any existing licences to find school specific pricing, so not suitable for renewals
    #
    # Intended to be used for a school moving to a MAT based contract..?
    def for_school(school:, product:, contract:)
      calculate(
        product:,
        contract:,
        number_of_pupils: school.number_of_pupils,
        number_of_meters: school.meters.main_meter.active.count,
        private_account: school.data_sharing_private?
      )
    end

    # Calculates a renewal price for an individual school. Uses the schools current
    # licence as the basis for the calculation, applying school or contract specific
    # pricing if set.
    #
    # FIXME: if school lapsed? call for_school? maybe just use last licence?
    def for_school_renewal(school:)
      licence = @school.licences.current.first
      return nil unless licence

      base_price = licence.school_specific_price || base_price(product: licence.contract.product,
                                contract: licence.contract,
                                number_of_pupils: school.number_of_pupils)

      return 0.0 if base_price == 0.0

      return base_price +
             metering_fee(product: licence.contract.product,
                          number_of_meters: school.meters.main_meter.active.count) +
             private_account_fee(product: licence.contract.product,
                                 private_account: school.data_sharing_private?)
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
      return 0.0 unless number_of_meters > 5
      product.metering_fee * (number_of_meters - 5)
    end

    def private_account_fee(product:, private_account: false)
      return 0.0 unless private_account
      return product.private_account_fee
    end
  end
end

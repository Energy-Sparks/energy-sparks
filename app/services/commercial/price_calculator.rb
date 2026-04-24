# frozen_string_literal: true

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
      base_price = base_price(product: contracted_product, contract:, number_of_pupils:)

      return Price::FREE if base_price == 0.0

      Price.new(
        base_price:,
        metering_fee: metering_fee(product: contracted_product, number_of_meters:),
        private_account_fee: private_account_fee(product: contracted_product, private_account:)
      )
    end

    # Calculates a price for a school under an existing contract. Does not
    # check for any existing licences to find school specific pricing, so not suitable for renewals
    def for_school(school:, product: nil, contract: nil)
      calculate(
        product:,
        contract:,
        number_of_pupils: school.number_of_pupils,
        number_of_meters: school.meters.main_meter.active.count,
        private_account: school.data_sharing_private?
      )
    end

    # Calculates a renewal price for an individual school. Uses the school's current licence
    # as the basis for the calculation, applying school or contract specific pricing if set.
    #
    # If the current school licence is for an alternate funder, then the renewal price will be based on
    # switching to using the terms of latest contract for the school's default contract holder. Or our
    # default product if they don't have a contract, or if the school is going to be self-funded.
    def for_school_renewal(school:)
      licence = school.licences.current.first
      return nil unless licence

      contract = renewal_contract(school, licence)
      product = renewal_product(contract)

      base_price = renewal_base_price(school, product, contract, licence)

      if base_price == 0.0
        Price::FREE
      else
        Price.new(
          base_price:,
          metering_fee: metering_fee(product:, number_of_meters: school.meters.main_meter.active.count),
          private_account_fee: private_account_fee(product:, private_account: school.data_sharing_private?)
        )
      end
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

      product.private_account_fee
    end

    # Determine contract to use for renewal estimate based on expected future funder
    def renewal_contract(school, licence)
      # Self-funded in future, assume switching to default product pricing
      if school.default_contract_holder.nil?
        nil
      # Switching from funded place
      elsif school.default_contract_holder != licence.contract.contract_holder
        school.default_contract_holder.contracts.by_end_date.first
      # Already funded by MAT, assume same contract
      else
        licence.contract
      end
    end

    # use same product as contract, or fall back to our default product
    def renewal_product(contract)
      contract&.product || Commercial::Product.default_product
    end

    # use existing school pricing or based on contract and product
    def renewal_base_price(school, product, contract, licence)
      licence.school_specific_price ||
        base_price(product:, contract:, number_of_pupils: school.number_of_pupils)
    end
  end
end

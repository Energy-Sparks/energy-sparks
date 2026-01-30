module Commercial
  class PriceCalculator
    def initialize(school)
      @school = school
      @licence = @school.licences.current.first
    end

    # TODO add method for calculating price based on contract/product/school characteristics?

    def calculate_price
      return nil unless @licence
      return base_price + additional_services
    end

    private

    def base_price
      return @licence.school_specific_price if @licence.school_specific_price
      return @licence.contract.agreed_school_price if @licence.contract.agreed_school_price

      number_of_pupils = @school.number_of_pupils
      if number_of_pupils <= contract.size_threshold
        contract.small_school_price
      else
        contract.large_school_price
      end
    end

    def additional_services
      metering_fee + private_account_fee
    end

    def metering_fee
      # FIXME main meters only, no solar
      # FIXME may need to look at inactive meters and their meter status (with a flag)
      meter_count = @school.meters.active.count
      return 0.0 unless meter_count > 5
      product.metering_fee * (meter_count - 5)
    end

    def private_account_fee
      return 0.0 unless @school.data_sharing_private?
      return product.private_account_fee
    end

    def contract
      @licence.contract
    end

    def product
      @licence.contract.product
    end
  end
end

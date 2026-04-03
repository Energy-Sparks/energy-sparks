module Commercial
  class Price
    attr_reader :base_price, :metering_fee, :private_account_fee

    def initialize(base_price:, metering_fee: 0.0, private_account_fee: 0.0)
      @base_price = base_price
      @metering_fee = metering_fee
      @private_account_fee = private_account_fee
    end

    FREE = new(base_price: 0.0).freeze

    def additional_fees?
      @metering_fee.positive? || @private_account_fee.positive?
    end

    def free?
      total.zero?
    end

    def total
      @base_price + @metering_fee + @private_account_fee
    end
  end
end

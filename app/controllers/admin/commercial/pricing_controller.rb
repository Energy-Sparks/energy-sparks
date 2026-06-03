module Admin::Commercial
  class PricingController < AdminController
    def show
      @product  = find_product(pricing_params[:product_id])
      @contract = find_contract(pricing_params[:contract_id])

      @number_of_pupils = param_or_default(pricing_params[:number_of_pupils], default: 1)
      @number_of_meters = param_or_default(pricing_params[:number_of_meters], default: 1)
      @private_account  = boolean_param(pricing_params[:private_account])

      @price = Commercial::PriceCalculator.new.calculate(
        product: @product,
        contract: @contract,
        number_of_pupils: @number_of_pupils,
        number_of_meters: @number_of_meters,
        private_account: @private_account
      )
    end

    private

    def pricing_params
      params.fetch(:pricing, {})
    end

    def find_product(id)
      return Commercial::Product.default_product if id.blank?
      Commercial::Product.find(id)
    end

    def find_contract(id)
      return nil if id.blank?
      Commercial::Contract.find_by(id: id)
    end

    def param_or_default(value, default:)
      value.present? ? value.to_i : default
    end

    def boolean_param(value)
      ActiveModel::Type::Boolean.new.cast(value)
    end
  end
end

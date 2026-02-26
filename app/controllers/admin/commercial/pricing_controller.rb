module Admin::Commercial
  class PricingController < AdminController
    def show
      pricing = params.fetch(:pricing, {})

      @school = find_school(pricing[:school_id])

      if @school && @school.licences.any?
        @licence = @school.licences.by_end_date.first
        @contract = @licence.contract
        @product = @licence.product
      else
        @product  = find_product(pricing[:product_id])
        @contract = find_contract(pricing[:contract_id])
      end

      @number_of_pupils = param_or_default(pricing[:number_of_pupils], default: default_pupils)
      @number_of_meters = param_or_default(pricing[:number_of_meters], default: default_meters)
      @private_account  = boolean_param(pricing[:private_account])

      @price = Commercial::PriceCalculator.new.calculate(
        product: @product,
        contract: @contract,
        number_of_pupils: @number_of_pupils,
        number_of_meters: @number_of_meters,
        private_account: @private_account
      )

      if @school
        @school_specific_price = Commercial::PriceCalculator.new.for_school_renewal(school: @school)
      end
    end

    private

    def find_product(id)
      return Commercial::Product.default_product if id.blank?
      Commercial::Product.find(id)
    end

    def find_contract(id)
      return nil if id.blank?
      Commercial::Contract.find_by(id: id)
    end

    def find_school(id)
      return nil if id.blank?
      School.find(id)
    end

    def default_pupils
      @school&.number_of_pupils || 1
    end

    def default_meters
      @school&.meters&.main_meter&.active&.count || 1
    end

    def param_or_default(value, default:)
      value.present? ? value.to_i : default
    end

    def boolean_param(value)
      @school.present? ? @school.data_sharing_private? : ActiveModel::Type::Boolean.new.cast(value)
    end
  end
end

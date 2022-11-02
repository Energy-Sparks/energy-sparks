module Admin
  class PriceConfigurationsController < AdminController
    def show
    end

    def create
      @errors = ActiveModel::Errors.new(PriceConfiguration.new)

      price_configuration_params.each_key do |price_configuration_key|
        price_configuration = PriceConfiguration.new(var: price_configuration_key)
        price_configuration.value = price_configuration_params[price_configuration_key].strip
        unless price_configuration.valid?
          @errors.merge!(price_configuration.errors)
        end
      end

      if @errors.any?
        render :show
      else
        price_configuration_params.each_key do |key|
          next if price_configuration_params[key].nil?

          PriceConfiguration.send("#{key}=", price_configuration_params[key].strip)
        end
        redirect_to admin_price_configuration_path, notice: "Price configuration was successfully updated."
      end
    end

    private

    def price_configuration_params
      params.require(:price_configuration).permit(:electricity_price, :solar_export_price, :gas_price, :oil_price)
    end
  end
end

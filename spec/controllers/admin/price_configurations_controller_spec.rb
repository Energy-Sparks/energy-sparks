require 'rails_helper'

RSpec.describe Admin::PriceConfigurationsController, type: :controller do
  context "As an admin user" do
    before(:each) do
      sign_in_user(:admin)
    end

    describe "POST #create" do
      context "with valid parameters" do
        it "fails to update a price configuration" do
          expect(
            [
              PriceConfiguration.electricity_price,
              PriceConfiguration.gas_price,
              PriceConfiguration.oil_price,
              PriceConfiguration.solar_export_price

            ]
            ).to eq(
              [
                BenchmarkMetrics::ELECTRICITY_PRICE,
                BenchmarkMetrics::GAS_PRICE,
                BenchmarkMetrics::OIL_PRICE,
                BenchmarkMetrics::SOLAR_EXPORT_PRICE
              ]
          )
          post :create, params: { price_configuration: { electricity_price: 'an invalid price', gas_price: 3000.999, oil_price: 4000.999, solar_export_price: 5000.999 } }
          expect(
            [
              PriceConfiguration.electricity_price,
              PriceConfiguration.gas_price,
              PriceConfiguration.oil_price,
              PriceConfiguration.solar_export_price

            ]
            ).to eq(
              [
                BenchmarkMetrics::ELECTRICITY_PRICE,
                BenchmarkMetrics::GAS_PRICE,
                BenchmarkMetrics::OIL_PRICE,
                BenchmarkMetrics::SOLAR_EXPORT_PRICE
              ]
          )
        end
      end

      context "with valid parameters" do
        it "updates a price configuration" do
          expect(
            [
              PriceConfiguration.electricity_price,
              PriceConfiguration.gas_price,
              PriceConfiguration.oil_price,
              PriceConfiguration.solar_export_price

            ]
            ).to eq(
              [
                BenchmarkMetrics::ELECTRICITY_PRICE,
                BenchmarkMetrics::GAS_PRICE,
                BenchmarkMetrics::OIL_PRICE,
                BenchmarkMetrics::SOLAR_EXPORT_PRICE
              ]
          )
          post :create, params: { price_configuration: { electricity_price: 2000.999, gas_price: 3000.999, oil_price: 4000.999, solar_export_price: 5000.999 } }
          expect(response).to redirect_to(admin_price_configuration_path)

          expect(
            [
              PriceConfiguration.electricity_price,
              PriceConfiguration.gas_price,
              PriceConfiguration.oil_price,
              PriceConfiguration.solar_export_price

            ]
            ).to eq(
              [
                2000.999,
                3000.999,
                4000.999,
                5000.999
              ]
          )
        end
      end
    end
  end
end

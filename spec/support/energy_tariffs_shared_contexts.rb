RSpec.shared_context "a school with meters" do
  let!(:school)             { create_active_school() }
  let!(:electricity_meter)  { create(:electricity_meter, school: school, mpan_mprn: '12345678901234') }
  let!(:gas_meter)          { create(:gas_meter, school: school, mpan_mprn: '999888777') }
end

RSpec.shared_context "with flat price electricity and gas tariffs" do
  let!(:gas_tariff)         { create(:energy_tariff, :with_flat_price, start_date: Date.new(2022,1,1), end_date: Date.new(2022,12,31), tariff_holder: tariff_holder, meter_type: :gas)}
  let!(:electricity_tariff)   { create(:energy_tariff, :with_flat_price, start_date: Date.new(2023,1,1), end_date: Date.new(2023,12,31), tariff_holder: tariff_holder, meter_type: :electricity)}
end

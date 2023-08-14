RSpec.shared_context "a school with meters" do
  let!(:school)             { create_active_school() }
  let!(:electricity_meter)  { create(:electricity_meter, school: school, mpan_mprn: '12345678901234') }
  let!(:gas_meter)          { create(:gas_meter, school: school, mpan_mprn: '999888777') }
end

RSpec.shared_context "a school with a flat price electricity tariff" do
  let!(:school)             { create_active_school() }
  let!(:energy_tariff)      { create(:energy_tariff, :with_flat_price, tariff_holder: school, fuel_type: :electricity)}
end

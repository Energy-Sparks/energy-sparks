require 'rails_helper'

describe 'School group SECR' do
  let(:school_group) { create(:school_group) }
  let(:school) { create(:school, school_group:, number_of_pupils: 1000) }
  let!(:meter) { create(:electricity_meter, school:) }
  let!(:gas_meter) { create(:gas_meter, school:) }

  before do
    travel_to(Date.new(2025, 5, 1))
    SecrCo2Equivalence.create!(year: 2023,
                               electricity_co2e: 0.207074,
                               electricity_co2e_co2: 0.20496,
                               transmission_distribution_co2e: 0.01830,
                               natural_gas_co2e: 0.18,
                               natural_gas_co2e_co2: 0.18256)
    MeterMonthlySummary.create!(meter: gas_meter, type: :consumption, year: 2023,
                                total: 1200, consumption: [100] * 12, quality: [:actual] * 12)
    MeterMonthlySummary.create!(meter:, type: :consumption, year: 2023,
                                total: 200 * 12, consumption: [200] * 12, quality: [:actual] * 12)
    MeterMonthlySummary.create!(meter:, type: :self_consume, year: 2023,
                                total: 50 * 12, consumption: [50] * 12, quality: [:actual] * 12)
    MeterMonthlySummary.create!(meter:, type: :export, year: 2023,
                                total: -25 * 12, consumption: [-25] * 12, quality: [:actual] * 12)
  end

  context 'when visiting the page' do
    context 'when not logged in' do
      before do
        visit school_group_secr_index_path(school_group)
      end

      it { expect(page).to have_content('You need to sign in or sign up before continuing') }
    end

    context 'when signed in' do
      before do
        sign_in(create(:group_admin, school_group: school_group))
        visit school_group_secr_index_path(school_group)
      end

      it 'displays title' do
        expect(page).to have_title('SECR Reporting Data')
        expect(page).to have_content('SECR Reporting Data')
      end

      it 'displays table 1' do
        expect(all('#table1 tbody tr').map { |tr| tr.all('td').map(&:text) }).to \
          eq([['Scope 1', '', ''],
              ['Gas consumption', '1200.0', '216.0'],
              ['Solar self consumption', '600.0', '0'],
              ['Total', '1800.0', '216.0'],
              ['Scope 2', '', ''],
              ['Purchased Electricity', '2400.0', '496.98'],
              ['Scope 3', '', ''],
              ['Electricity transmission and distribution', '-', '43.92'],
              ['Total', '4200.0', '756.9'],
              ['Solar export', '300.0', ''],
              ['Net', '3900.0', ''],
              ['Intensity ratio', '', ''],
              ['Tonnes CO2e per pupil', '0.2564', '']])
      end

      it 'displays table 2' do
        expect(all('#table2 tbody tr').map { |tr| tr.all('td').map(&:text) }).to \
          eq([['Electricity kg CO₂e', '0.207074'],
              ['Electricity kg CO₂e of CO₂', '0.20496'],
              ['Transmission & distribution kg CO₂e', '0.0183'],
              ['Natural gas kg CO₂e', '0.18'],
              ['Natural gas kg CO₂e of CO₂', '0.18256']])
      end

      context 'when downloading CSV reports' do
        it 'downloads electricity data' do
          click_on('electricity consumption')
          expect_csv(meter, 200)
        end

        it 'downloads gas data' do
          click_on('gas consumption')
          expect_csv(gas_meter, 100)
        end

        it 'downloads self consumption data' do
          click_on('solar self consumption')
          expect_csv(meter, 50)
        end

        it 'downloads solar export data' do
          click_on('solar export')
          expect_csv(meter, -25)
        end

        def expect_csv(meter, amount)
          expect(page.body).to eq(
            'School,MPXN,Meter serial,Meter name,Consumption for the year,' \
            'Sep-2023,Quality,Oct-2023,Quality,Nov-2023,Quality,Dec-2023,Quality,Jan-2024,Quality,Feb-2024,Quality,' \
            'Mar-2024,Quality,Apr-2024,Quality,May-2024,Quality,Jun-2024,Quality,Jul-2024,Quality,Aug-2024,Quality,' \
            "Earliest validated reading,Latest validated reading\n" \
            "#{school.name},#{meter.mpan_mprn},,#{meter.name}," \
            "#{([(amount * 12).to_f.round(2).to_s] + [amount.to_f.round(2).to_s, 'A'] * 12).join(',')},,\n")
        end
      end
    end
  end
end

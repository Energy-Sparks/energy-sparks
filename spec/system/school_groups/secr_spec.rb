require 'rails_helper'

describe 'School group SECR' do
  let(:school_group) { create(:school_group) }
  let(:school) { create(:school, school_group:, number_of_pupils: 1000) }
  let!(:meter) { create(:electricity_meter, school:) }
  let!(:gas_meter) { create(:gas_meter, school:) }

  before do
    travel_to(Date.new(2025, 5, 1))
    SecrCo2Equivalence.create!(year: 2025,
                               electricity_co2e: 0.207074,
                               electricity_co2e_co2: 0.20496,
                               transmission_distribution_co2e: 0.01830,
                               natural_gas_co2e: 0.18,
                               natural_gas_co2e_co2: 0.18256)
    MeterMonthlySummary.create!(meter: gas_meter, type: :consumption, year: 2024,
                                total: 1200, consumption: [100] * 12, quality: [:actual] * 12)
    MeterMonthlySummary.create!(meter:, type: :consumption, year: 2024,
                                total: 200 * 12, consumption: [200] * 12, quality: [:actual] * 12)
    MeterMonthlySummary.create!(meter:, type: :self_consume, year: 2024,
                                total: 50 * 12, consumption: [50] * 12, quality: [:actual] * 12)
    MeterMonthlySummary.create!(meter:, type: :export, year: 2024,
                                total: -25 * 12, consumption: [-25] * 12, quality: [:actual] * 12)
  end

  context 'when visiting the page' do
    context 'when not logged in' do
      before do
        visit school_group_secr_index_path(school_group)
      end

      it { expect(page).to have_content('You need to sign in or sign up before continuing') }
    end

    context 'when signed in as a different group admin' do
      before do
        sign_in(create(:group_admin, school_group: create(:school_group)))
        visit school_group_secr_index_path(school_group)
      end

      it { expect(page).to have_content('You are not authorized to access this page.') }
    end

    context 'when signed in as a group admin in the same group' do
      before do
        sign_in(create(:group_admin, school_group: school_group))
        visit school_group_secr_index_path(school_group)
      end

      it 'displays title' do
        expect(page).to have_title('SECR Reporting Data')
        expect(page).to have_content('SECR Reporting Data')
      end

      it 'displays the table' do
        click_on('Data')
        expect(all('tbody tr').map { |tr| tr.all('td').map(&:text) }).to \
          eq([['Scope 1 Total', '1,200.0', '', '0.22'],
              ['Gas consumption', '1,200.0', '0.18', '0.22'],
              ['Scope 2 Total', '3,000.0', '', '0.5'],
              ['Purchased electricity', '2,400.0', '0.207074', '0.5'],
              ['Solar self consumption', '600.0', '', '0.0'],
              ['Scope 3 Total', '2,400.0', '', '0.04'],
              ['Electricity transmission and distribution', '2,400.0', '0.0183', '0.04'],
              ['Total', '4,200.0', '', '0.76'],
              ['Solar export', '300.0', '0.207074', '0.06'],
              ['Net', '3,900.0', '', '0.69'],
              ['Intensity ratio', '', '', ''],
              ['Tonnes CO2e per pupil', '', '', '0.2564']])
      end

      context 'when downloading CSV reports' do
        it 'downloads electricity data' do
          click_on('electricity consumption 2024/25')
          expect_csv(meter, 200, 2024)
        end

        it 'downloads gas data' do
          click_on('gas consumption 2024/25')
          expect_csv(gas_meter, 100, 2024)
        end

        it 'downloads self consumption data' do
          click_on('solar self consumption 2024/25')
          expect_csv(meter, 50, 2024)
        end

        it 'downloads solar export data' do
          click_on('solar export 2024/25')
          expect_csv(meter, -25, 2024)
        end

        it 'downloads previous electricity data' do
          click_on('electricity consumption 2023/24')
          expect_csv(meter, nil, 2023)
        end

        def expect_csv(meter, amount, year)
          months = [*%w[Sep Oct Nov Dec].map { |month| "#{month}-#{year}" },
                    *%w[Jan Feb Mar Apr May Jun Jul Aug].map { |month| "#{month}-#{year + 1}" }]
                   .map { |month| [month, 'Quality'] }
          header = 'School,Number of pupils,MPXN,Meter serial,Meter name,Consumption for the year,' \
                   "#{months.flatten.join(',')},Earliest validated reading,Latest validated reading\n"
          body = unless amount.nil?
                   "#{school.name},#{school.number_of_pupils},#{meter.mpan_mprn},,#{meter.name}," \
                     "#{[(amount * 12).to_f.round(2).to_s, *([amount.to_f.round(2).to_s, 'A'] * 12)].join(',')},,\n"
                 end
          expect(page.body).to eq([header, body].join)
        end
      end
    end
  end
end

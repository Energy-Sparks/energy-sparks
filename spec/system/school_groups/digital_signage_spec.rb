require 'rails_helper'

describe 'School group digital signage' do
  let(:school_group) { create(:school_group) }
  let!(:school) { create(:school, :with_fuel_configuration, school_group: school_group) }

  before do
    school.configuration.update(aggregate_meter_dates: {
      electricity: { start_date: Time.zone.yesterday, end_date: Time.zone.today },
      gas: { start_date: Time.zone.yesterday, end_date: Time.zone.today },
    })
  end

  context 'when visiting the page' do
    context 'when not logged in' do
      before do
        visit school_group_digital_signage_index_path(school_group)
      end

      it { expect(page).to have_content('You need to sign in or sign up before continuing') }
    end

    context 'when signed in' do
      before do
        sign_in(create(:group_admin, school_group: school_group))
        visit school_group_digital_signage_index_path(school_group)
      end

      it 'displays title' do
        expect(page).to have_title(I18n.t('pupils.digital_signage.index.title'))
        expect(page).to have_content(I18n.t('pupils.digital_signage.index.title'))
      end

      it 'displays group specific text' do
        expect(page).to have_content(I18n.t('pupils.digital_signage.index.school_group.data_sharing.title'))
        expect(page).to have_content(I18n.t('pupils.digital_signage.index.school_group.downloads.title'))
      end

      it 'displays download_links' do
        within('#equivalences-downloads') do
          expect(page).to have_link(href: equivalences_school_group_digital_signage_index_path(school_group, format: :csv))
        end
        within('#charts-downloads') do
          expect(page).to have_link(href: charts_school_group_digital_signage_index_path(school_group, format: :csv))
        end
      end

      context 'when downloading equivalence links' do
        subject(:csv) { CSV.parse(page.body, liberal_parsing: true) }

        before do
          within('#equivalences-downloads') do
            click_on('Download')
          end
        end

        it 'downloads expected data' do
          expect(csv).to eq([
                              %w[School Fuel Link],
                              [school.name, 'Electricity', pupils_school_digital_signage_equivalences_url(school, :electricity, domain: 'example.com')],
                              [school.name, 'Gas', pupils_school_digital_signage_equivalences_url(school, :gas, domain: 'example.com')],
                            ])
        end
      end

      context 'when downloading chart links' do
        subject(:csv) { CSV.parse(page.body, liberal_parsing: true) }

        before do
          within('#charts-downloads') do
            click_on('Download')
          end
        end

        let(:expected_csv) do
          rows = []
          rows << ['School', 'Fuel', 'Chart Type', 'Description', 'Link']
          [:electricity, :gas].each do |fuel_type|
            Pupils::DigitalSignageController::CHART_TYPES.each do |chart_type|
              rows << [
                school.name,
                I18n.t("common.#{fuel_type}"),
                I18n.t("pupils.digital_signage.index.charts.#{chart_type}.title"),
                I18n.t("pupils.digital_signage.index.charts.#{chart_type}.description"),
                pupils_school_digital_signage_charts_url(school, fuel_type, chart_type, domain: 'example.com')
              ]
            end
          end
          rows
        end

        it 'downloads expected data' do
          expect(csv).to eq(expected_csv)
        end
      end
    end
  end
end

require 'rails_helper'

describe 'School group priorities page' do
  let!(:school_group) { create(:school_group, :with_active_schools, public: true) }
  let!(:school) { create(:school, school_group: school_group, number_of_pupils: 10, floor_area: 200.0) }

  let(:alert_type_rating) do
    create(:alert_type_rating,
           management_priorities_active: true,
           alert_type: create(:alert_type),
           rating_from: 6.0,
           rating_to: 10.0)
  end

  it_behaves_like 'an access controlled group advice page' do
    let(:path) { priorities_school_group_advice_path(school_group) }
  end

  before do
    content_version = create(:alert_type_rating_content_version,
               colour: :negative,
               management_priorities_title: 'Spending too much money on heating',
               alert_type_rating: alert_type_rating)
    create(:alert,
           school: school,
           alert_generation_run: create(:alert_generation_run, school: school),
           alert_type: content_version.alert_type_rating.alert_type,
           rating: 6.0,
           template_data: {
                 one_year_saving_kwh: '2,200 kWh',
                 average_one_year_saving_£: '£1,000',
                 one_year_saving_co2: '1,100 kg CO2',
                 time_of_year_relevance: 5.0
           })
    Alerts::GenerateContent.new(school).perform
  end

  context 'when not signed in' do
    before do
      visit priorities_school_group_advice_path(school_group)
    end

    it_behaves_like 'a school group advice page' do
      let(:breadcrumb) { I18n.t('advice_pages.index.priorities.title') }
      let(:title) { I18n.t('school_groups.advice.priorities.title') }
    end

    it_behaves_like 'it contains the expected data table', aligned: false, rows: false do
      let(:table_id) { '#school-group-priorities' }
      let(:expected_header) do
        [
          ['', 'Savings'],
          ['Fuel', '', 'Schools', 'Energy (kWh)', 'Cost (£)', 'CO2 (kg)']
        ]
      end
    end

    it 'has expected content in table' do
      within('#school-group-priorities') do
        expect(page).to have_content('Spending too much money on heating')
        expect(page).to have_content('£1,000')
        expect(page).to have_content('1,100')
        expect(page).to have_content('2,200')
      end
    end

    it 'has expected priority count in the navbar' do
      within('#nav-section-priorities') do
        expect(page).to have_content('(1)')
      end
    end

    context 'when downloading as a CSV' do
      before do
        click_link(I18n.t('school_groups.download_as_csv'), id: 'download-priority-actions-school-group-csv')
      end

      it_behaves_like 'it exports a group CSV correctly' do
        let(:action_name) { I18n.t('school_groups.titles.priority_actions') }
        let(:expected_csv) do
          [['Fuel', 'Description', 'Schools', 'Energy (kWh)', 'Cost (£)', 'CO2 (kg)'],
           ['Gas', 'Spending too much money on heating', '1', '2,200', '£1,000', '1,100']
          ]
        end
      end
    end

    context 'with the modal showing' do
      before do
        first(:link, 'Spending too much money on heating').click
      end

      it 'displays the expected explanation' do
        expect(page).to have_content('This action has been identified as a priority for the following schools')
      end

      it_behaves_like 'it contains the expected data table', sortable: false do
        let(:table_id) { "#school-priorities-#{alert_type_rating.id}"  }
        let(:expected_header) do
          [
            ['', 'Savings', ''],
            ['School', 'Energy (kWh)', 'Cost (£)', 'CO2 (kg)', '']
          ]
        end
        let(:expected_rows) do
          [[school.name, '2,200', '£1,000', '1,100', '']]
        end
      end

      context 'when the download button is clicked' do
        before do
          click_link(I18n.t('school_groups.download_as_csv'), id: 'download-priority-actions-school-csv')
        end

        it_behaves_like 'it exports a group CSV correctly' do
          let(:action_name) { I18n.t('school_groups.titles.priority_actions') }
          let(:expected_csv) do
            [['Fuel', 'Description', 'School', 'Number of pupils', 'Floor area (m2)', 'Energy (kWh)', 'Cost (£)', 'CO2 (kg)'],
             ['Gas', 'Spending too much money on heating', school.name, '10', '200.0', '2200', '£1000', '1100']
            ]
          end
        end
      end
    end
  end

  context 'when signed in as the group admin' do
    before do
      sign_in(create(:group_admin, school_group:))
      visit priorities_school_group_advice_path(school_group)
    end

    context 'with the modal showing' do
      before do
        first(:link, 'Spending too much money on heating').click
      end

      it_behaves_like 'it contains the expected data table', sortable: false do
        let(:table_id) { "#school-priorities-#{alert_type_rating.id}"  }
        let(:expected_header) do
          [
            ['', 'Savings', ''],
            ['School', 'Cluster', 'Energy (kWh)', 'Cost (£)', 'CO2 (kg)', '']
          ]
        end
        let(:expected_rows) do
          [[school.name, I18n.t('common.labels.not_set'), '2,200', '£1,000', '1,100', '']]
        end
      end

      context 'when a cluster has been added' do
        let!(:cluster) { create(:school_group_cluster, schools: [school]) }

        before do
          refresh
          first(:link, 'Spending too much money on heating').click
        end

        it_behaves_like 'it contains the expected data table', sortable: false do
          let(:table_id) { "#school-priorities-#{alert_type_rating.id}"  }
          let(:expected_header) do
            [
              ['', 'Savings', ''],
              ['School', 'Cluster', 'Energy (kWh)', 'Cost (£)', 'CO2 (kg)', '']
            ]
          end
          let(:expected_rows) do
            [[school.name, cluster.name, '2,200', '£1,000', '1,100', '']]
          end
        end
      end

      context 'when the download button is clicked' do
        before do
          click_link(I18n.t('school_groups.download_as_csv'), id: 'download-priority-actions-school-csv')
        end

        it_behaves_like 'it exports a group CSV correctly' do
          let(:action_name) { I18n.t('school_groups.titles.priority_actions') }
          let(:expected_csv) do
            [['Fuel', 'Description', 'School', 'Cluster', 'Number of pupils', 'Floor area (m2)', 'Energy (kWh)', 'Cost (£)', 'CO2 (kg)'],
             ['Gas', 'Spending too much money on heating', school.name, I18n.t('common.labels.not_set'), '10', '200.0', '2200', '£1000', '1100']
            ]
          end
        end
      end
    end
  end
end

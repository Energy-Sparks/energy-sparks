require 'rails_helper'

describe 'School group priorities page' do
  let!(:school_group) { create(:school_group, :with_active_schools, public: true) }
  let!(:school) { create(:school, school_group: school_group, number_of_pupils: 10, floor_area: 200.0) }

  include_context 'school group priority actions' do
    let(:school_with_saving) { school }
  end

  before do
    visit priorities_school_group_advice_path(school_group)
  end

  it_behaves_like 'a school group advice page' do
    let(:breadcrumb) { I18n.t('advice_pages.index.priorities.title') }
  end

  it 'displays list of actions' do
    expect(page).to have_css('#school-group-priorities')
    within('#school-group-priorities') do
      expect(page).to have_content('Spending too much money on heating')
      expect(page).to have_content('£1,000')
      expect(page).to have_content('1,100')
      expect(page).to have_content('2,200')
    end
  end

  context 'when downloading as a CSV' do
    before do
      click_link('Download as CSV', id: 'download-priority-actions-school-group-csv')
    end

    it_behaves_like 'it downloads a CSV correctly' do
      let(:action_name) { I18n.t('school_groups.titles.priority_actions') }
    end

    it 'has the expected contents' do
      expect(page.source).to eq "Fuel,Description,Schools,Energy (kWh),Cost (£),CO2 (kg)\nGas,Spending too much money on heating,1,\"2,200\",\"£1,000\",\"1,100\"\n"
    end
  end

  context 'with the modal showing' do
    before do
      first(:link, 'Spending too much money on heating').click
    end

    it 'has a list of schools' do
      expect(page).to have_content('Savings')
      expect(page).to have_content('This action has been identified as a priority for the following schools')
      expect(page).to have_content(school.name)
    end

    context 'when when downloading as a CSV' do
      before do
        click_link('Download as CSV', id: 'download-priority-actions-school-csv')
      end

      it_behaves_like 'it downloads a CSV correctly' do
        let(:action_name) { I18n.t('school_groups.titles.priority_actions') }
      end

      it 'has the expected contents' do
        expect(page.source).to eq "Fuel,Description,School,Number of pupils,Floor area (m2),Energy (kWh),Cost (£),CO2 (kg)\nGas,Spending too much money on heating,#{school.name},10,200.0,0,£1000,1100\n"
      end
    end

    it_behaves_like 'a page not showing the cluster column'
  end
end

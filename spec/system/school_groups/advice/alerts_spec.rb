require 'rails_helper'

describe 'School group alerts page' do
  let!(:school_group) { create(:school_group, :with_active_schools, public: true) }

  let(:content_version) do
    create(:alert_type_rating_content_version,
           colour: :negative,
           group_dashboard_title: 'Spending too much money on gas',
           alert_type_rating: create(:alert_type_rating,
                                     group_dashboard_alert_active: true,
                                     alert_type: create(:alert_type),
                                     rating_from: 6.0,
                                     rating_to: 10.0))
  end

  before do
    school_group.schools.each do |school|
      create(:alert,
             school: school,
             alert_generation_run: create(:alert_generation_run, school: school),
             alert_type: content_version.alert_type_rating.alert_type,
             rating: 6.0,
             variables: {
                   one_year_saving_kwh: 1.0,
                   average_one_year_saving_gbp: 2.0,
                   one_year_saving_co2: 3.0,
                   time_of_year_relevance: 5.0
             })
    end
  end

  it_behaves_like 'an access controlled group advice page' do
    let(:path) { priorities_school_group_advice_path(school_group) }
  end

  context 'when not signed in' do
    before do
      visit alerts_school_group_advice_path(school_group)
    end

    it_behaves_like 'a school group advice page' do
      let(:breadcrumb) { I18n.t('advice_pages.index.alerts.title') }
      let(:title) { I18n.t('school_groups.advice.alerts.title') }
    end

    it 'has expected alert count in the navbar' do
      within('#nav-section-alerts') do
        expect(page).to have_content('(1)')
      end
    end

    it 'displays the grouped alerts' do
      within('#advice-alerts') do
        expect(html).to have_content(content_version.group_dashboard_title.to_plain_text)
        expect(html).to have_content(I18n.t('advice_pages.alerts.groups.advice'))
      end
    end
  end
end

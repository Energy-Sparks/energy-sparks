require 'rails_helper'

describe 'school group chart settings' do
  let(:school_group) { create(:school_group) }

  shared_examples 'a working chart update page' do
    it { expect(page).to have_content(I18n.t('school_groups.chart_updates.index.group_chart_settings'))}

    it 'has breadcrumbs' do
      expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name,
                                                                           'Chart settings'])
    end


    it 'displays correct form options' do
      SchoolGroup.default_chart_preferences.each_key do |preference|
        expect(page).to have_content(I18n.t("school_groups.chart_updates.index.default_chart_preference.#{preference}"))
      end
    end

    context 'when changing the options' do
      before do
        choose 'Display chart data in £, where available'
        click_on 'Update all schools in this group'
      end

      it 'applies the updates' do
        expect(school_group.reload.default_chart_preference).to eq('cost')
        expect(school_group.schools.map(&:chart_preference).uniq).to eq(['cost'])
      end
    end
  end

  context 'when not logged in' do
    before do
      visit school_group_chart_updates_path(school_group)
    end

    it_behaves_like 'the page requires a login'
  end

  context 'when logged in as a user without permissions' do
    let(:school) { create(:school, school_group:) }

    before do
      sign_in(create(:school_admin, school: school))
      visit school_group_chart_updates_path(school_group)
    end

    it_behaves_like 'redirects to school group page'
  end

  context 'when logged in as group admin' do
    before do
      create :school, active: true, school_group: school_group, chart_preference: 'default'
      create :school, active: true, school_group: school_group, chart_preference: 'carbon'
      create :school, active: true, school_group: school_group, chart_preference: 'usage'

      sign_in(create(:group_admin, school_group:))
      visit school_group_chart_updates_path(school_group)
    end

    it_behaves_like 'a working chart update page'
  end
end

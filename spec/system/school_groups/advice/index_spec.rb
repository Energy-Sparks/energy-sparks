require 'rails_helper'

describe 'School group advice index page' do
  let!(:school_group) { create(:school_group, public: true) }
  let!(:school) { create(:school, :with_fuel_configuration, school_group: school_group) }

  include_context 'school group recent usage'

  context 'when not logged in' do
    before do
      visit school_group_advice_path(school_group)
    end

    it_behaves_like 'it contains the expected data table', aligned: true do
      let(:table_id) { '#school-group-recent-usage-electricity' }
      let(:expected_header) do
        [
          ['School', 'Last week', 'Last month', 'Last year']
        ]
      end
      let(:expected_rows) do
        [
          [school.name, '-16%', '-16%', '-16%']
        ]
      end
    end

    context 'when toggling to kWh', :js do
      before do
        choose(option: 'usage')
      end

      it_behaves_like 'it contains the expected data table', aligned: true do
        let(:table_id) { '#school-group-recent-usage-electricity' }
        let(:expected_header) do
          [
            ['School', 'Last week', 'Last month', 'Last year']
          ]
        end
        let(:expected_rows) do
          [
            [school.name, '910', '910', '910']
          ]
        end
      end
    end

    it_behaves_like 'schools are filtered by permissions'
    it_behaves_like 'a group advice page secr nav link', display: false
  end

  context 'when logged in as group admin' do
    before do
      sign_in(create(:group_admin, school_group:))
      visit school_group_advice_path(school_group)
    end

    it_behaves_like 'schools are filtered by permissions', admin: true
    it_behaves_like 'a group advice page secr nav link', display: true
  end

  context 'when logged in as group admin for a different group' do
    before do
      sign_in(create(:group_admin, school_group: create(:school_group)))
      visit school_group_advice_path(school_group)
    end

    it_behaves_like 'schools are filtered by permissions', admin: false
    it_behaves_like 'a group advice page secr nav link', display: false
  end
end

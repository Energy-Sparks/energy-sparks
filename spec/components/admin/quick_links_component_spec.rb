# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::QuickLinksComponent, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(user:)
  end

  let(:user) { create(:admin) }

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    describe 'select school group box' do
      let!(:school_groups) { create_list(:school_group, 2, :with_active_schools, default_issues_admin_user: user) }

      it { expect(html).to have_content('Select School Group') }

      it 'has a school group selection box' do
        expect(html).to have_select(:school_group_id, options: ['select'] + school_groups.sort_by(&:name).pluck(:name))
        expect(html).to have_css("form[action='#{admin_dashboard_path(user)}'][method='get']")
      end
    end

    describe 'select school box' do
      let!(:schools) { create_list(:school, 2, school_group: create(:school_group, default_issues_admin_user: user)) }

      it { expect(html).to have_content('Select School') }

      it 'has a school selection box' do
        expect(html).to have_select(:school_id, options: ['select'] + schools.sort_by(&:name).pluck(:name))
        expect(html).to have_css("form[action='#{admin_dashboard_path(user)}'][method='get']")
      end
    end

    describe 'find MPXN box' do
      it { expect(html).to have_content('Find MPXN') }

      it 'has an MPXN search box' do
        expect(html).to have_css("form[action='#{admin_find_school_by_mpxn_index_path}'][method='get']")
      end
    end

    describe 'find URN box' do
      it { expect(html).to have_content('Find URN') }

      it 'has a URN search box' do
        expect(html).to have_css("form[action='#{admin_find_school_by_urn_index_path}'][method='get']")
      end
    end
  end
end

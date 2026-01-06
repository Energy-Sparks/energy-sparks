# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Managing school group partners', :include_application_helper, :school_groups do
  let!(:admin) { create(:admin) }
  let!(:partners) { create_list(:partner, 3) }

  shared_examples 'a partner management form' do
    it 'has a partner link' do
      expect(page).to have_content(school_group.name)
      expect(page).to have_content(partners.first.display_name)
    end

    it 'has blank partner fields for all partners' do
      expect(page.find_field(partners.first.name).value).to be_blank
      expect(page.find_field(partners.second.name).value).to be_blank
      expect(page.find_field(partners.last.name).value).to be_blank
    end

    context 'when assigning partners via text box position' do
      before do
        fill_in partners.last.name, with: '1'
        fill_in partners.second.name, with: '2'
        click_on 'Update associated partners', match: :first
        click_on 'Manage partners'
      end

      it 'partners are ordered' do
        expect(school_group.partners).to contain_exactly(partners.last, partners.second)
        expect(school_group.school_group_partners.first.position).to be 1
        expect(school_group.school_group_partners.last.position).to be 2
      end

      context 'when then clearing one order position' do
        before do
          fill_in partners.last.name, with: ''
          click_on 'Update associated partners', match: :first
          click_on 'Manage partners'
        end

        it 'removes partner' do
          expect(school_group.partners).to contain_exactly(partners.second)
        end
      end
    end
  end

  before do
    sign_in(admin)
    visit admin_school_group_path(school_group)

    click_on 'Manage partners'
  end

  context 'with an organisation group' do
    let!(:school_group) { create(:school_group) }

    it_behaves_like 'a partner management form'
  end

  context 'with a project group' do
    let!(:school_group) { create(:school_group, group_type: :project) }

    it_behaves_like 'a partner management form'
  end
end

# frozen_string_literal: true

require 'rails_helper'

shared_examples 'a report group page with valid attributes' do |action:|
  before do
    fill_in 'Title en', with: 'New title'
    fill_in 'Description en', with: 'New description'
    fill_in 'Position', with: '2'
    click_on 'Save'
  end

  it { expect(page).to have_content("Report group was successfully #{action}") }

  it do
    expect(page).to have_selector(:table_row, {
                                                'Title' => 'New title',
                                                'Description' => 'New description',
                                                'Position' => 2
})
  end
end

shared_examples 'a report group page with invalid attributes' do
  before do
    fill_in 'Title en', with: ''
    fill_in 'Position', with: ''
    click_on 'Save'
  end

  it { expect(page).to have_content("Title en\ncan't be blank") }
  it { expect(page).to have_no_content("Description en\ncan't be blank") }
  it { expect(page).to have_content("Position *\nis not a number and can't be blank") }
end

describe 'admin comparisons report groups', :include_application_helper do
  let!(:admin)  { create(:admin) }
  let!(:report_group) { create(:report_group, title: 'Electricity') }
  let!(:report) { }

  describe 'when not logged in' do
    context 'when viewing the index' do
      before do
        visit admin_comparisons_report_groups_url
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when editing a report' do
      before do
        visit edit_admin_comparisons_report_group_url(report_group)
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'when logged in' do
    before do
      sign_in(admin)
    end

    describe 'Viewing the index' do
      before do
        visit admin_comparisons_report_groups_url
      end

      it 'lists report group' do
        within('table') do
          expect(page).to have_selector(:table_row,
                                        { 'Title' => report_group.title,
                                          'Description' => report_group.description,
                                          'Position' => report_group.position })
        end
      end

      it { expect(page).to have_link('Edit') }

      context 'when clicking the edit button' do
        before { click_link('Edit') }

        it 'shows report group edit page' do
          expect(page).to have_current_path(edit_admin_comparisons_report_group_path(report_group))
        end

        it_behaves_like 'a report group page with invalid attributes'
        it_behaves_like 'a report group page with valid attributes', action: 'updated'
      end

      it { expect(page).to have_link('New report group') }

      context 'when clicking the new button' do
        before { click_link('New report') }

        it 'shows report group new page' do
          expect(page).to have_current_path(new_admin_comparisons_report_group_path)
        end

        it_behaves_like 'a report group page with invalid attributes'
        it_behaves_like 'a report group page with valid attributes', action: 'created'
      end

      context 'when the report group is empty' do
        it { expect(page).not_to have_link('Delete', class: 'disabled') }
        it { expect(page).to have_link('Delete') }

        context 'when clicking on the delete button' do
          before { click_link('Delete') }

          it 'shows index page' do
            expect(page).to have_current_path(admin_comparisons_report_groups_path)
          end

          it 'no longer lists report' do
            within('table') do
              expect(page).to have_no_selector(:table_row,
                                                { 'Title' => report_group.title,
                                                  'Description' => report_group.description,
                                                  'Position' => report_group.position })
            end
          end
        end
      end

      context 'when the report group contains reports' do
        let(:report) { create(:report, report_group: report_group) }

        it { expect(page).to have_link('Delete', class: 'disabled') }
      end
    end
  end
end

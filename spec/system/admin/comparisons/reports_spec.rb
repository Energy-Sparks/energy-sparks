require 'rails_helper'

shared_examples 'a report page with valid attributes' do |action:|
  before do
    fill_in 'Key', with: 'New key'
    fill_in 'Title en', with: 'New title'

    select 'Custom', from: 'Reporting period'
    fill_in 'Current label', with: 'Current label'
    fill_in 'Current start date', with: '01/01/2024'
    fill_in 'Current end date', with: '01/02/2024'
    fill_in 'Previous label', with: 'Previous label'
    fill_in 'Previous start date', with: '01/01/2023'
    fill_in 'Previous end date', with: '01/02/2023'

    fill_in_trix '#report_introduction_en', with: 'New introduction'
    fill_in_trix '#report_notes_en', with: 'New notes'
    check 'Public'
    click_on 'Save'
  end

  it { expect(page).to have_content("Report was successfully #{action}") }
  it { expect(page).to have_selector(:table_row, { 'Key' => 'New key', 'Title' => 'New title', 'Reporting period' => 'Custom (comparing Current label to Previous label' }) }
end

shared_examples 'a report page with invalid attributes' do
  before do
    fill_in 'Key', with: ''
    fill_in 'Title en', with: ''

    select 'Custom', from: 'Reporting period'
    click_on 'Save'
  end

  it { expect(page).to have_content("Key *\ncan't be blank") }
  it { expect(page).to have_content("Title en\ncan't be blank") }
  it { expect(page).to have_content("Current label *\ncan't be blank") }
  it { expect(page).to have_content("Current start date *\ncan't be blank") }
  it { expect(page).to have_content("Current end date *\ncan't be blank") }
  it { expect(page).to have_content("Previous label *\ncan't be blank") }
  it { expect(page).to have_content("Previous start date *\ncan't be blank") }
  it { expect(page).to have_content("Previous end date *\ncan't be blank") }
  it { expect(page).not_to have_content("Introduction en\ncan't be blank") }
  it { expect(page).not_to have_content("Notes en\ncan't be blank") }
end

describe 'admin comparisons reports', type: :system, include_application_helper: true do
  let!(:admin)  { create(:admin) }
  let!(:report) { create(:report) }

  describe 'when not logged in' do
    context 'when viewing the index' do
      before do
        visit admin_comparisons_reports_url
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when editing a report' do
      before do
        visit edit_admin_comparisons_report_url(report)
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
        visit admin_comparisons_reports_url
      end

      it 'lists report' do
        within('table') do
          expect(page).to have_selector(:table_row, { 'Key' => report.key, 'Reporting period' => report.reporting_period.humanize, 'Title' => report.title })
        end
      end

      it { expect(page).to have_link('Edit') }

      context 'when clicking the edit button' do
        before { click_link('Edit') }

        it 'shows report edit page' do
          expect(page).to have_current_path(edit_admin_comparisons_report_path(report))
        end

        it_behaves_like 'a report page with invalid attributes'
        it_behaves_like 'a report page with valid attributes', action: 'updated'
      end

      it { expect(page).to have_link('New report') }

      context 'when clicking the new button' do
        before { click_link('New report') }

        it 'shows report new page' do
          expect(page).to have_current_path(new_admin_comparisons_report_path)
        end

        it_behaves_like 'a report page with invalid attributes'
        it_behaves_like 'a report page with valid attributes', action: 'created'
      end

      it { expect(page).to have_link('Delete') }

      context 'when clicking on the delete button' do
        before { click_link('Delete') }

        it 'shows index page' do
          expect(page).to have_current_path(admin_comparisons_reports_path)
        end

        it 'no longer lists report' do
          within('table') do
            expect(page).not_to have_selector(:table_row, { 'Key' => report.key, 'Reporting period' => report.reporting_period.humanize, 'Title' => report.title })
          end
        end
      end
    end
  end
end

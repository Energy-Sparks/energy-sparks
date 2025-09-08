require 'rails_helper'

RSpec.describe 'school batch run', type: :system do
  let!(:school) { create(:school) }
  let!(:user) { create(:admin, school: school)}

  before do
    sign_in(user)
    visit school_batch_runs_path(school)
  end

  context 'when school is not set to process data' do
    let!(:school) { create(:school, process_data: false) }

    it { expect(page).not_to have_button('Start regeneration')}

    it { expect(page).to have_content('Cannot regenerate a school that has not been set to process data')}
  end

  context 'when set to process data' do
    context 'with no existing runs' do
      it { expect(page).to have_button('Start regeneration')}
      it { expect(page).not_to have_content('Previous runs')}
    end

    context 'with an existing run' do
      let!(:school_batch_run) do
        school_batch_run = create(:school_batch_run, school: school)
        school_batch_run.info('analysing..')
        school_batch_run.error('bogus..')
        school_batch_run
      end

      before do
        visit school_batch_runs_path(school)
      end

      it { expect(page).to have_button('Start regeneration')}
      it { expect(page).to have_content('Previous runs')}
      it { expect(page).to have_content('pending') }

      context 'when viewing run' do
        before do
          click_on('View')
        end

        it 'shows school batch runs' do
          expect(page).to have_content('Status: pending')
          expect(page).to have_content('analysing..')
          expect(page).to have_content('bogus..')
        end
      end
    end
  end
end

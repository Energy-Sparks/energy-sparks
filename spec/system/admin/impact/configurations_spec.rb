# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin impact configurations' do
  let!(:admin) { create(:admin) }
  let!(:school_group) { create(:school_group, name: 'Test Academy Trust') }
  let!(:impact_configuration) do
    create(:impact_report_configuration, school_group: school_group, show_engagement: true)
  end

  describe 'when not logged in' do
    context 'when visiting the index' do
      before do
        visit admin_impact_configurations_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when editing a configuration' do
      before do
        visit edit_admin_impact_configuration_path(school_group)
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'when logged in as a non admin user' do
    let(:staff) { create(:staff) }

    before { sign_in(staff) }

    context 'when visiting the index' do
      before do
        visit admin_impact_configurations_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You are not authorized to view that page.')
      end
    end

    context 'when editing a configuration' do
      before do
        visit edit_admin_impact_configuration_path(school_group)
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You are not authorized to view that page.')
      end
    end
  end

  # very basic tests, better tests needed as form gets more complex
  describe 'when logged in as admin' do
    before { sign_in(admin) }

    context 'when viewing the index' do
      before do
        visit admin_impact_configurations_path
      end

      it 'lists the school groups' do
        expect(page).to have_content(school_group.name)
      end

      it 'shows configuration status' do
        expect(page).to have_content('true') # Make a better test here
      end
    end

    context 'when editing an existing configuration' do
      before do
        visit edit_admin_impact_configuration_path(school_group)
      end

      it 'shows the show_engagement checkbox' do
        expect(page).to have_field('Show Engagement Section', checked: true)
      end

      context 'with valid attributes' do
        before do
          uncheck 'Show Engagement Section'
          click_on 'Save'
        end

        it 'shows success message' do
          expect(page).to have_content('Configuration was successfully updated.')
        end

        it 'updates the configuration' do
          expect(impact_configuration.reload.show_engagement).to be(false)
        end
      end

      context 'with valid attributes keeping engagement shown' do
        before do
          check 'Show Engagement Section'
          click_on 'Save'
        end

        it 'shows success message' do
          expect(page).to have_content('Configuration was successfully updated.')
        end

        it 'keeps the configuration unchanged' do
          expect(impact_configuration.reload.show_engagement).to be(true)
        end
      end
    end
  end
end

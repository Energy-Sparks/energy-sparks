require 'rails_helper'

RSpec.describe 'admin school onboardings', type: :system do

  let(:admin)             { create(:admin) }
  let(:school_group)      { create :school_group }

  let!(:onboardings)      { 3.times.collect { create :school_onboarding, :with_events, :with_school, event_names: [:email_sent], school_group: school_group } }

  describe 'when logged in' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Manage school onboarding'
    end

    context 'for selected' do
      describe "first onboarding checked" do
        let(:onboarding) { onboardings.first }
        before do
          check "school_group_school_onboarding_ids_#{onboarding.id}"
        end

        describe "Make selected visible" do
          before do
            onboarding.school.update!(visible: false)
          end
          context "without consents" do
            before do
              click_button "Make selected visible"
            end
            it { expect(page).to have_content('School cannot be made visible as we dont have a record of consent') }
            it { expect(page).to_not have_content('Schools made visible') }
            it { expect(onboarding.reload.school).to_not be_visible }
          end

          context "with consent" do
            before do
              create(:consent_grant, school: onboarding.school)
              click_button "Make selected visible"
            end
            it { expect(page).to have_content('Schools made visible') }
            it { expect(onboarding.reload.school).to be_visible }
          end
        end

        describe "Send reminders to selected" do
          before do
            click_button "Send reminders to selected"
          end
          it { expect(page).to have_current_path(admin_school_onboardings_path(school_group: school_group)) }
          it { expect(onboarding.reload.events.map(&:event)).to include('reminder_sent') }
          it { expect(page).to have_content('Reminders sent') }
        end
      end
    end

    context 'Nothing selected' do
      describe "Make selected visible" do
        before do
          click_button "Make selected visible"
        end
        it { expect(page).to_not have_content('Schools made visible') }
        it { expect(page).to have_content('Nothing selected') }
      end

      describe "Send reminders to selected" do
        before do
          click_button "Send reminders to selected"
        end
        it { expect(page).to_not have_content('Reminders sent') }
        it { expect(page).to have_content('Nothing selected') }
      end
    end

    context "Checking all", js: true do
      before do
        check "check-all-#{school_group.id}"
      end

      it "checks all checkboxes" do
        school_group.school_onboardings.each do |onboarding|
          expect(page).to have_checked_field("school_group_school_onboarding_ids_#{onboarding.id}")
        end
      end

      context "unchecking all" do
        before do
          uncheck "check-all-#{school_group.id}"
        end
        it "unchecks all checkboxes" do
          school_group.school_onboardings.each do |onboarding|
            expect(page).to_not have_checked_field("school_group_school_onboarding_ids_#{onboarding.id}")
          end
        end
      end
    end

  end
end
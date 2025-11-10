# frozen_string_literal: true

RSpec.shared_examples 'admin school group onboardings' do
  before do
    setup_data
    after_setup_data
  end

  context 'selectable actions' do
    let(:school_group_onboardings) do
      Array.new(3) do
        create(:school_onboarding, :with_school, school_group:, created_by: admin)
      end
    end
    let(:setup_data) { school_group_onboardings }

    context 'for selected' do
      describe 'first onboarding checked' do
        let(:onboarding) { school_group_onboardings.first }

        before do
          check "school_group_school_onboarding_ids_#{onboarding.id}"
        end

        describe 'Make selected visible' do
          before { onboarding.school.update!(visible: false) }

          it { expect(onboarding.school).not_to be_visible }
          it { expect(onboarding).to be_incomplete }

          context 'with consent' do
            before do
              Wisper.clear
              Wisper.subscribe(Onboarding::OnboardingDataEnabledListener.new)
              create(:consent_grant, school: onboarding.school)
              click_button 'Make selected visible'
            end

            after { Wisper.clear }

            it { expect(page).to have_content("#{school_group.name} schools made visible") }
            it { expect(onboarding.reload.school).to be_visible }
            it { expect(ActionMailer::Base.deliveries.count).to eq(2) }

            it 'sends onboarding complete email' do
              email = ActionMailer::Base.deliveries.first
              expect(email.to).to include('operations@energysparks.uk')
              expect(email.subject).to eq("#{onboarding.school.name} () has completed the onboarding process")
            end

            it 'sends school live email' do
              email = ActionMailer::Base.deliveries.second
              expect(email.to).to include(onboarding.created_user.email)
              expect(email.subject).to eq("#{onboarding.school.name} is now live on Energy Sparks")
            end
          end
        end

        describe 'Send reminders to selected' do
          before do
            @back = current_path
            click_button 'Send reminders to selected'
          end

          it { expect(page).to have_current_path(@back) }
          it { expect(onboarding.reload.events.map(&:event)).to include('reminder_sent') }
          it { expect(page).to have_content("#{school_group.name} schools reminders sent") }

          it 'sends email' do
            email = ActionMailer::Base.deliveries.last
            expect(email.subject).to include("Don't forget to set up your school on Energy Sparks")
            expect(email.html_part.decoded).to include(onboarding_path(onboarding))
          end
        end
      end
    end

    context 'Nothing selected' do
      describe 'Make selected visible' do
        before do
          click_button 'Make selected visible'
        end

        it { expect(page).to have_no_content('schools made visible') }
        it { expect(page).to have_content('Nothing selected') }
      end

      describe 'Send reminders to selected' do
        before do
          click_button 'Send reminders to selected'
        end

        it { expect(page).to have_no_content('schools reminders sent') }
        it { expect(page).to have_content('Nothing selected') }
      end
    end

    context 'Checking all', :js do
      before do
        check "check-all-#{school_group.id}"
      end

      it "checks all group's checkboxes" do
        school_group.school_onboardings.each do |onboarding|
          expect(page).to have_checked_field("school_group_school_onboarding_ids_#{onboarding.id}")
        end
      end

      context 'then unchecking all' do
        before do
          uncheck "check-all-#{school_group.id}"
        end

        it 'unchecks all checkboxes' do
          school_group.school_onboardings.each do |onboarding|
            expect(page).to have_unchecked_field("school_group_school_onboarding_ids_#{onboarding.id}")
          end
        end
      end
    end
  end

  context 'when linking to issues' do
    context 'when there is an associated school' do
      let(:setup_data) { create(:school_onboarding, :with_school, school_group:) }

      it 'has a school issues link' do
        within 'table' do
          expect(page).to have_link('Issues', href: admin_school_issues_path(setup_data.school))
        end
      end

      describe 'when trying to complete onboarding' do
        let(:onboarding) { setup_data }

        before do
          check "school_group_school_onboarding_ids_#{setup_data.id}"
        end

        describe 'it does not make visible' do
          before do
            click_button 'Make selected visible'
          end

          it { expect(setup_data).to be_incomplete }
        end
      end
    end

    context 'when without an associated school' do
      let(:setup_data) { create(:school_onboarding, school_group:) }

      it 'has a onboarding issues link' do
        within 'table' do
          expect(page).to have_link('Issues', href: admin_school_onboarding_issues_path(setup_data))
        end
      end

      describe 'when trying to complete onboarding' do
        let(:onboarding) { setup_data }

        before do
          check "school_group_school_onboarding_ids_#{setup_data.id}"
        end

        describe 'it does not make visible' do
          before do
            click_button 'Make selected visible'
          end

          it { expect(setup_data.school).to be_nil }
          it { expect(setup_data).to be_incomplete }
        end
      end
    end
  end
end

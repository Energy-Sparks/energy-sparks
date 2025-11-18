RSpec.shared_examples 'admin dashboard messages' do |permitted: true|
  context 'when permitted', if: permitted do
    let(:message) { 'Hello message' }
    let!(:messageable_school) { messageable.is_a?(SchoolGroup) ? create(:school, school_group: messageable) : messageable }

    context 'No message set' do
      it { expect(page).to have_content "No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}" }
      it { expect(page).to have_selector('#dashboard-message a', text: 'Set message') }
      it { expect(page).not_to have_selector('#dashboard-message a', text: 'Edit') }
      it { expect(page).not_to have_selector('#dashboard-message a', text: 'Delete') }

      context "Clicking on 'Set message'" do
        before do
          within('#dashboard-message') do
            click_link 'Set message'
          end
        end

        it { expect(page).to have_content("Dashboard Message for #{messageable.name}") }
        it { expect(page).to have_field('Message', with: '') }
        it { expect(page).to have_button('Save') }
        it { expect(page).to have_link('Back') }
        it { expect(page).not_to have_link('Delete') }

        context 'and clicking link back' do
          before { click_link 'Back' }

          it { expect(page).to have_content "No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}" }
        end


        context 'and saving a new message' do
          before do
            fill_in 'Message', with: message
            click_on 'Save'
          end

          it { expect(page).to have_content message }

          context 'visiting a school dashboard' do
            before { visit school_path(messageable_school, switch: true) }

            it { expect(page).to have_content(message) }
          end

          context 'visiting a non-messageable school dashboard' do
            let!(:non_messageable_school) { messageable.is_a?(SchoolGroup) ? create(:school, :with_school_group) : create(:school, school_group: messageable.school_group) }

            before { visit school_path(non_messageable_school, switch: true) }

            it { expect(page).not_to have_content(message) }
          end
        end

        context 'when message is invalid' do
          before do
            fill_in 'Message', with: ''
            click_on 'Save'
          end

          it { expect(page).to have_content("Message *\ncan't be blank") }
        end
      end
    end

    context 'a message is already set' do
      let(:setup_data) { messageable.create_dashboard_message(message: message) }

      it { expect(page).not_to have_content "No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}" }
      it { expect(page).to have_content message }
      it { expect(page).to have_selector('#dashboard-message a', text: 'Edit') }
      it { expect(page).to have_selector('#dashboard-message a', text: 'Delete') }

      context "Clicking on 'Edit'" do
        before do
          within('#dashboard-message') do
            click_link 'Edit'
          end
        end

        it { expect(page).to have_field('Message', with: message) }

        context 'and changing message' do
          before do
            fill_in 'Message', with: 'Changed message'
            click_on 'Save'
          end

          it { expect(page).to have_content 'Changed message' }
        end

        it { expect(page).to have_link('Delete') }

        context "Clicking on 'Delete'" do
          before do
            click_on 'Delete'
          end

          it { expect(page).to have_content("No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}") }

          context 'visiting a school dashboard' do
            before { visit school_path(messageable_school, switch: true) }

            it { expect(page).not_to have_content(message) }
          end
        end
      end

      context "Clicking on 'Delete'" do
        before do
          within '#dashboard-message' do
            click_on 'Delete'
          end
        end

        it { expect(page).to have_content("No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}") }

        context 'visiting a school dashboard' do
          before { visit school_path(messageable_school, switch: true) }

          it { expect(page).not_to have_content(message) }
        end
      end
    end
  end

  context 'when not permitted', unless: permitted do
    it 'panel is not shown' do
      expect(page).not_to have_selector('#dashboard-message a', text: 'Set message')
      expect(page).not_to have_selector('#dashboard-message a', text: 'Edit')
      expect(page).not_to have_selector('#dashboard-message a', text: 'Delete')
    end
  end
end

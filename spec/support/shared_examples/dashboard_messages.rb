RSpec.shared_examples 'admin dashboard messages' do |permitted: true|
  context 'when permitted', if: permitted do
    let(:message) { 'Hello message' }
    let!(:messageable_school) do
      messageable.is_a?(SchoolGroup) ? create(:school, school_group: messageable) : messageable
    end

    context 'when no message is set' do
      it {
        expect(page).to have_text "No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}"
      }

      it { expect(page).to have_css('#dashboard-message a', text: 'Set message') }
      it { expect(page).to have_no_css('#dashboard-message a', text: 'Edit') }
      it { expect(page).to have_no_css('#dashboard-message a', text: 'Delete') }

      context "when clicking on 'Set message'" do
        before do
          within('#dashboard-message') do
            click_link 'Set message'
          end
        end

        it { expect(page).to have_text("Dashboard Message for #{messageable.name}") }
        it { expect(page).to have_field('Message', with: '') }
        it { expect(page).to have_button('Save') }
        it { expect(page).to have_link('Back') }
        it { expect(page).to have_no_link('Delete') }

        context 'when clicking link back' do
          before { click_link 'Back' }

          it {
            expect(page).to have_text "No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}"
          }
        end

        context 'when saving a new message' do
          before do
            fill_in 'Message', with: message
            click_on 'Save'
          end

          it { expect(page).to have_text message }

          context 'when visiting a school dashboard' do
            before { visit school_path(messageable_school, switch: true) }

            it { expect(page).to have_text(message) }
          end

          context 'when visiting a non-messageable school dashboard' do
            let!(:non_messageable_school) do
              if messageable.is_a?(SchoolGroup)
                create(:school,
                       :with_school_group)
              else
                create(:school,
                       school_group: messageable.school_group)
              end
            end

            before { visit school_path(non_messageable_school, switch: true) }

            it { expect(page).to have_no_text(message) }
          end
        end

        context 'when message is invalid' do
          before do
            fill_in 'Message', with: ''
            click_on 'Save'
          end

          it { expect(page).to have_text("Message *\ncan't be blank") }
        end
      end
    end

    context 'when a message is already set' do
      let(:setup_data) { messageable.create_dashboard_message(message: message) }

      it {
        expect(page).to have_no_text "No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}"
      }

      it { expect(page).to have_text message }
      it { expect(page).to have_css('#dashboard-message a', text: 'Edit') }
      it { expect(page).to have_css('#dashboard-message a', text: 'Delete') }

      context "when clicking on 'Edit'" do
        before do
          within('#dashboard-message') do
            click_link 'Edit'
          end
        end

        it { expect(page).to have_field('Message', with: message) }

        context 'when changing message' do
          before do
            fill_in 'Message', with: 'Changed message'
            click_on 'Save'
          end

          it { expect(page).to have_text 'Changed message' }
        end

        it { expect(page).to have_link('Delete') }

        context "when clicking on 'Delete'" do
          before do
            click_on 'Delete'
          end

          it {
            expect(page).to have_text("No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}")
          }

          context 'when visiting a school dashboard' do
            before { visit school_path(messageable_school, switch: true) }

            it { expect(page).to have_no_text(message) }
          end
        end
      end

      context "when clicking on 'Delete'" do
        before do
          within '#dashboard-message' do
            click_on 'Delete'
          end
        end

        it {
          expect(page).to have_text("No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}")
        }

        context 'when visiting a school dashboard' do
          before { visit school_path(messageable_school, switch: true) }

          it { expect(page).to have_no_text(message) }
        end
      end
    end
  end

  context 'when not permitted', unless: permitted do
    it 'panel is not shown' do
      expect(page).to have_no_css('#dashboard-message a', text: 'Set message')
      expect(page).to have_no_css('#dashboard-message a', text: 'Edit')
      expect(page).to have_no_css('#dashboard-message a', text: 'Delete')
    end
  end
end

RSpec.shared_examples 'a dashboard message' do
  let(:message) { 'Dashboard message' }

  context 'when there is a message' do
    let(:setup_data) { messageable.create_dashboard_message(message: message) }

    it { expect(page).to have_text(message) }
  end

  context 'when there is not a message' do
    it { expect(page).to have_no_text(message) }
  end
end

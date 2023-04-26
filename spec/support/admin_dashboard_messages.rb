RSpec.shared_examples "admin dashboard messages" do | permitted: true |

  context "when permitted", if: permitted do
    let(:message) { 'Hello message' }
    let!(:messageable_school) { messageable.is_a?(SchoolGroup) ? create(:school, school_group: messageable) : messageable }

    context "No message set" do
      it { expect(page).to have_content "No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}" }
      it { expect(page).to have_link('Set message') }
      context "Clicking on 'Set message'" do
        before { click_link "Set message" }
        it { expect(page).to have_content("Dashboard Message for #{messageable.name}") }
        it { expect(page).to have_link("Back") }
        context "and clicking link back" do
          before { click_link "Back" }
          it { expect(page).to have_content "No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}" }
        end
        it { expect(page).to have_field('Message', with: '') }
        it { expect(page).to_not have_link('Delete') }
        context "and saving a new message" do
          before do
            fill_in 'Message', with: message
            click_on 'Save'
          end
          it { expect(page).to have_content message }
          context "visiting a school dashboard" do
            before { visit school_path(messageable_school, switch: true) }
            it { expect(page).to have_content(message) }
          end
          context "visiting a non-messageable school dashboard" do
            let!(:non_messageable_school) { messageable.is_a?(SchoolGroup) ? create(:school, :with_school_group) : create(:school, school_group: messageable.school_group) }
            before { visit school_path(non_messageable_school, switch: true) }
            it { expect(page).to_not have_content(message) }
          end
        end
        context "when message is invalid" do
          before do
            fill_in 'Message', with: ''
            click_on 'Save'
          end
          it { expect(page).to have_content("Message *\ncan't be blank") }
        end
      end
    end

    context "a message is already set" do
      let(:setup_data) { messageable.create_dashboard_message(message: message) }
      it { expect(page).to have_content message }
      it { expect(page).to have_link('Set message') }
      context "Clicking on 'Set message'" do
        before { click_link "Set message" }
        it { expect(page).to have_field('Message', with: message) }
        context "and changing message" do
          before do
            fill_in 'Message', with: "Changed message"
            click_on 'Save'
          end
          it { expect(page).to have_content "Changed message" }
        end
        it { expect(page).to have_link('Delete') }
        context "and deleting message" do
          before do
            click_on 'Delete'
          end
          it { expect(page).to have_content("No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}") }
          context "visiting a school dashboard" do
            before { visit school_path(messageable_school, switch: true) }
            it { expect(page).to_not have_content(message) }
          end
        end
      end
    end
  end
  context "when not permitted", unless: permitted do
    it "panel is not shown" do
      expect(page).to_not have_content('Set message')
    end
  end
end

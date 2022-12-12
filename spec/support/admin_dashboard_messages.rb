RSpec.shared_examples "admin dashboard messages" do
  let(:message) { 'Hello message' }
  context "No message set" do
    it { expect(page).to have_content "No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}" }
    it { expect(page).to have_link('Set message') }
    context "Clicking on 'Set message'" do
      before { click_link "Set message" }
      it { expect(page).to have_content("Dashboard Message for #{messageable.name} #{messageable.model_name.to_s.titleize}") }
      it { expect(page).to have_link("View #{messageable.model_name.human.downcase}") }
      context "and clicking link back" do
        before { click_link "View #{messageable.model_name.human.downcase}" }
        it { expect(page).to have_content "#{messageable.name.to_s.capitalize} #{messageable.model_name.to_s.titleize}"}
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
          let!(:school) { messageable.is_a?(School) ? messageable : create(:school, school_group: school_group) }
          before { visit school_path(school, switch: true) }
          it { expect(page).to have_content message }
        end
      end
      context "when message is invalid" do
        before do
          fill_in 'Message', with: ''
          click_on 'Save'
        end
        it { expect(page).to have_content "Message *\ncan't be blank" }
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
        it { expect(page).to have_content "No message is currently set to display on dashboards for this #{messageable.model_name.human.downcase}" }
        context "visiting a school dashboard" do
          let!(:school) { messageable.is_a?(School) ? messageable : create(:school, school_group: school_group) }
          before { visit school_path(school, switch: true) }
          it { expect(page).to_not have_content message }
        end
      end
    end
  end
end

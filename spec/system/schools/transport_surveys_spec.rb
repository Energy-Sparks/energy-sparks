require 'rails_helper'

describe 'TransportSurveys', type: :system do

  let!(:school)            { create(:school) }
  let!(:transport_type)    { create(:transport_type) }

  # admin / group admin / school admin / staff - can manage Transport Surveys, Transport Survey Responses
  # pupil - as above except deleting Surveys and Transport Survey Responses
  # public user - read access only for everything (but not the intro)

  [:admin, :group_admin, :school_admin, :staff].each do |user_type|
    describe "as a #{user_type} user who can carry out surveys" do
      let(:user) { create(user_type) }

      before(:each) do
        sign_in(user)
      end

      context "viewing the introduction" do
        before(:each) do
          visit intro_school_transport_surveys_path(school)
          # save_and_open_page
        end

        it { expect(page).to have_content('Transport surveys') }
        it { expect(page).to have_link('Start surveying') }

        context "and surveying" do
          before(:each) do
            click_on 'Start surveying'
          end

          it { expect(page).to have_content("Surveying on #{Date.today}") }

          context "and submitting a default response" do
            before(:each) do
              click_button 'submit'
            end
            it "lists responses" do 
              expect(page).to have_content("Responses for: #{Date.today}")
              # save_and_open_page
            end
            it "displays added response" do
              expect(page).to have_content(transport_type.name)
            end
          end
        end
      end
    end
  end

  # Surveying only (not managing) user of transport surveys
  describe 'as a pupil' do

    let!(:pupil) { create(:pupil, school: school)}
    let!(:transport_survey) { create(:transport_survey, school: school) }

    context "viewing transport surveys index" do
      before(:each) do
        visit school_transport_surveys_path(school)
      end

      it "should be able to see a created transport survey" do
        expect(page).to have_content("#{transport_survey.run_on}")
      end
    end
  end

  # Read-only user of transport surveys
  describe 'as a public user' do
    context "viewing the introduction" do
      before :each do
        visit intro_school_transport_surveys_path(school)
      end

      it { expect(page).to_not have_content('Transport surveys') }
    end

  end
end
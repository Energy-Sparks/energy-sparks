require 'rails_helper'

describe 'TransportSurveys', type: :system do

  let!(:school)            { create(:school, :with_school_group) }
  let!(:transport_type)    { create(:transport_type) }

  # admin / group admin / school admin / staff - can manage Transport Surveys, Transport Survey Responses
  # pupil - as above except deleting Surveys and Transport Survey Responses
  # public user - read access only for everything (but not the intro)

  MANAGING_USER_TYPES = [:admin, :group_admin, :school_admin, :staff]
  SURVEYING_USER_TYPES = MANAGING_USER_TYPES + [:pupil]

  SURVEYING_USER_TYPES.each do |user_type|
    describe "as a #{user_type} user who can carry out surveys" do
      let(:user) { create(user_type, school: school) }

      before(:each) do
        sign_in(user)
      end

      context "viewing the introduction" do
        before(:each) do
          visit intro_school_transport_surveys_path(school)
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
            end
            it "displays added response" do
              expect(page).to have_content(transport_type.name)
            end
            it "shows link to collect more responses" do
              expect(page).to have_link('Collect more responses')
            end
          end
        end
      end
    end
  end

  MANAGING_USER_TYPES.each do |user_type|
    describe "as a #{user_type} user who can delete surveys and responses" do
      let!(:user) { create(user_type, school: school) }

      # not a big fan of if statements in rspec - it may be refactored out later on
      before(:each) do
        user.school_group = school.school_group if user_type == :group_admin
      end

      let!(:transport_survey) { create(:transport_survey, school: school) }
      let!(:transport_survey_response) { create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type) }

      before(:each) do
        sign_in(user)
      end
      context "viewing transport surveys index" do
        before(:each) do
          visit school_transport_surveys_path(school)
        end

        it "shows created transport survey" do
          expect(page).to have_content("#{transport_survey.run_on}")
        end

        it "shows delete button" do
          expect(page).to have_link('Delete')
        end

        context "and deleting transport survey" do
          before(:each) do
            click_link('Delete')
          end
          it "removes transport survey" do
            expect(page).to_not have_content("#{transport_survey.run_on}")
          end
        end

        context "and viewing responses" do
          before(:each) do
            click_link("#{Date.today}")
          end

          it "lists responses" do
            expect(page).to have_content("Responses for: #{Date.today}")
          end

          it "displays added response" do
            expect(page).to have_content(transport_survey_response.run_identifier)
          end

          context "and deleteing response" do
            before(:each) do
              # save_and_open_page
              click_link('Delete')
            end
            it "removes response" do
              expect(page).to_not have_content("#{transport_survey_response.run_identifier}")
            end
          end
        end
      end
    end
  end

  describe 'as a pupil who cannot delete transport surveys or responses' do
    let!(:pupil) { create(:pupil, school: school)}
    let!(:transport_survey) { create(:transport_survey, school: school) }
    let!(:transport_survey_response) { create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type) }

    before(:each) do
      sign_in(pupil)
    end

    context "viewing transport surveys index" do
      before(:each) do
        visit school_transport_surveys_path(school)
      end

      it "shows created transport survey" do
        expect(page).to have_content("#{transport_survey.run_on}")
      end

      it "shows surveying link" do
        expect(page).to have_link('Start surveying')
      end

      it "doesn't show survey delete button" do
        expect(page).to_not have_link('Delete')
      end

      context "and viewing responses" do
        before(:each) do
          click_link("#{Date.today}")
        end

        it "shows link to collect more responses" do
          expect(page).to have_link('Collect more responses')
        end

        it "doesn't show delete link" do
          expect(page).to_not have_link('Delete')
        end
      end
    end
  end

  describe 'as a public user with read only access' do
    context "viewing the introduction" do
      before :each do
        visit intro_school_transport_surveys_path(school)
      end
      it { expect(page).to_not have_content('Transport surveys') }
    end

    context "viewing transport surveys" do
      let!(:transport_survey) { create(:transport_survey, school: school) }

      before(:each) do
        visit school_transport_surveys_path(school)
      end

      it "shows created transport survey" do
        expect(page).to have_content("#{transport_survey.run_on}")
      end

      it "doesn't show surveying link" do
        expect(page).to_not have_link('Start surveying')
      end

      it "doesn't show survey delete button" do
        expect(page).to_not have_link('Delete')
      end

      context "and viewing responses" do
        before(:each) do
          click_link("#{Date.today}")
        end

        it "doesn't show link to collect more responses" do
          expect(page).to_not have_link('Collect more responses')
        end

        it "doesn't show delete link" do
          expect(page).to_not have_link('Delete')
        end
      end
    end
  end
end


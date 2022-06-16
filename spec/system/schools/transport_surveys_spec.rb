require 'rails_helper'
include ApplicationHelper

describe 'TransportSurveys', type: :system do


  let!(:school)            { create(:school, :with_school_group) }
  let!(:transport_type)    { create(:transport_type, can_share: true) }

  describe "Abilities" do
    # admin / group admin / school admin / staff - can manage Transport Surveys, Transport Survey Responses
    # pupil - as above except deleting Surveys and Transport Survey Responses
    # public user - read access only for everything (but not the start page)

    MANAGING_USER_TYPES = [:admin, :group_admin, :school_admin, :staff]
    SURVEYING_USER_TYPES = MANAGING_USER_TYPES + [:pupil]

    SURVEYING_USER_TYPES.each do |user_type|
      describe "as a #{user_type} user who can carry out surveys" do
        let(:user) { create(user_type, school: school) }

        before(:each) do
          sign_in(user)
        end

        context "viewing the start page" do
          before(:each) do
            visit start_school_transport_surveys_path(school)
          end

          it { expect(page).to have_content('Today\'s travel to school survey') }
          it { expect(page).to have_content('Survey today') }
          it { expect(page).to have_content('Javascript must be enabled to use this functionality.') }
          it { expect(page).to have_link('View all transport surveys') }
          it { expect(page).to_not have_css('#survey_nav') }

          context "and clicking the 'View all transport surveys' button" do
            before(:each) do
              click_link 'View all transport surveys'
            end
            it { expect(page).to have_content('Survey date') }
          end
        end
      end
    end

    MANAGING_USER_TYPES.each do |user_type|
      describe "as a #{user_type} user who can delete surveys and manage & delete responses" do
        let!(:user) { create(user_type, school: school) }

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
            expect(page).to have_content(nice_dates(transport_survey.run_on))
          end

          it "shows view results button" do
            expect(page).to have_link('View results')
          end

          it "shows manage button" do
            expect(page).to have_link('Manage')
          end

          it "shows delete button" do
            expect(page).to have_link('Delete')
          end

          context "and managing responses" do
            before(:each) do
              within('table') do
                click_link("Manage")
              end
            end

            it "shows results" do
              within("table") do
                expect(page).to have_content("Survey time")
              end
            end

            it "displays added response" do
              expect(page).to have_content(nice_date_times(transport_survey_response.surveyed_at))
            end

            context "and deleting response" do
              before(:each) do
                within('table') do
                  click_link('Delete')
                end
              end
              it "removes response" do
                expect(page).to_not have_content(nice_date_times(transport_survey_response.surveyed_at))
              end
            end
          end

          context "and deleting transport survey" do
            before(:each) do
              within('table') do
                click_link('Delete')
              end
            end
            it "removes transport survey" do
              expect(page).to_not have_content(nice_dates(transport_survey.run_on))
            end
          end
        end
      end
    end

    describe 'as a pupil who cannot delete transport surveys or manage responses' do
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
          expect(page).to have_content(nice_dates(transport_survey.run_on))
        end

        it "shows surveying link" do
          expect(page).to have_link('Start surveying today')
        end

        it "shows view results button" do
          expect(page).to have_link('View results')
        end

        it "doesn't show manage button" do
          expect(page).to_not have_link('Manage')
        end

        it "doesn't show survey delete button" do
          expect(page).to_not have_link('Delete')
        end

        context "and viewing results" do
          before(:each) do
            click_link("View results")
          end

          it "shows results page" do
              expect(page).to have_css('#transport_surveys_pie')
          end

          it "doesn't show link to manage responses" do
            expect(page).to_not have_link('Manage responses')
          end

          it "shows surveying links" do
            expect(page).to_not have_link('Start surveying today')
            expect(page).to have_link('Survey today')
          end

          it "shows link to View all transport surveys" do
            expect(page).to have_link('View all transport surveys')
          end
        end
      end
    end

    describe 'as a public user with read only access' do
      context "viewing the start page" do
        before :each do
          visit start_school_transport_surveys_path(school)
        end
        it { expect(page).to_not have_content('Travel to School Surveys') }
      end

      context "viewing transport surveys index" do
        let!(:transport_survey) { create(:transport_survey, school: school) }

        before(:each) do
          visit school_transport_surveys_path(school)
        end

        it "shows created transport survey" do
          expect(page).to have_content(nice_dates(transport_survey.run_on))
        end

        it "shows view results button" do
          expect(page).to have_link('View results')
        end

        it "doesn't show surveying link" do
          expect(page).to_not have_link('Start surveying today')
          expect(page).to_not have_link('Survey today')
        end

        it "doesn't show survey delete button" do
          expect(page).to_not have_link('Delete')
        end

        it "doesn't show manage button" do
          expect(page).to_not have_link('Manage')
        end

        context "and viewing results" do
          before(:each) do
            click_link("View results")
          end

          it "shows results page" do
              expect(page).to have_css('#transport_surveys_pie')
          end

          it "doesn't show link to Survey today" do
            expect(page).to_not have_link('Survey today')
          end

          it "doesn't show link to Manage responses" do
            expect(page).to_not have_link('Manage responses')
          end
        end
      end
    end
  end
end

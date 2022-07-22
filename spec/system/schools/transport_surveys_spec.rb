require 'rails_helper'
include ApplicationHelper

describe 'TransportSurveys', type: :system do

  let!(:school)            { create(:school, :with_school_group) }
  let!(:transport_type)    { create(:transport_type, category: :car, can_share: true) }

  describe "Transport survey results page" do
    describe 'as a public user with read only access' do

      let(:transport_survey) { create(:transport_survey, school: school) }
      let(:categories) { [] }
      let(:cols) { ["Transport category", "Total pupils & staff", "Percentage pupils & staff"] }

      context "with no results" do
        before do
          visit school_transport_survey_path(school, transport_survey)
        end
        it { expect(page).to have_content("No responses have been collected") }
      end

      context "with a zero carbon result" do
        before do
          transport_type = create(:transport_type, category: 'public_transport', kg_co2e_per_km: 0)
          create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type, passengers: 1, journey_minutes: 5)
          visit school_transport_survey_path(school, transport_survey)
        end
        it { expect(page).to have_content("1 pupil or staff member included in this survey generated 0.0kg carbon by travelling to school") }
        it { expect(page).to have_content("That's Carbon Neutral 🌳!") }
        it { expect(page).to have_content("0% walked or cycled, generating zero CO2") }
        it { expect(page).to have_content("100% travelled by public transport") }
        it { expect(page).to have_content("0% used park and stride") }
        it { expect(page).to have_content("0% travelled by car") }
      end

      context "with a carbon result" do
        before(:each) do
          categories.each do |cat|
            transport_type = create(:transport_type, category: cat, kg_co2e_per_km: 0.17148)
            create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type, passengers: 1, journey_minutes: 5)
          end
          visit school_transport_survey_path(school, transport_survey)
        end

        context "with one result" do
          let(:categories) { [:car] }
          it { expect(page).to have_content("That's the same as charging 276 smart phones 📱!") }
          it { expect(page).to have_content("That's the same as 1 veggie dinner 🥗!") }
          it { expect(page).to have_content("That's the same as 50 hours of TV 📺!") }
          it { expect(page).to have_content("That's the same as playing 10 hours of computer games 🎮!") }
          it { expect(page).to_not have_content("would absorb this amount of CO2 in 1 day 🌳!") }
          it { expect(page).to_not have_content("meat dinner") }
          it { expect(page).to_not have_content("That's Carbon Neutral 🌳!") }


          it { expect(page).to have_content("1 pupil or staff member included in this survey generated 0.46kg carbon by travelling to school") }
          it { expect(page).to have_content("0% walked or cycled, generating zero CO2") }
          it { expect(page).to have_content("0% travelled by public transport") }
          it { expect(page).to have_content("0% used park and stride") }
          it { expect(page).to have_content("100% travelled by car") }

          it { expect(page).to have_css('#transport_surveys_pie') }

          it "displays a table of transport type results" do
            within('table') do
              rows = [['Walking and cycling', 0, '0%'], ['Car', 1, '100%'], ['Public transport', 0, '0%'], ['Park and stride', 0, '0%'], ['Other', 0, '0%']]
              rows.each do |row|
                expect(page).to have_selector(:table_row, cols.zip(row).to_h)
              end
            end
          end
        end

        context "with more than one result" do
          let(:categories) { [:car, :walking_and_cycling, :public_transport, :park_and_stride, nil] }
          it { expect(page).to have_content("1 tree would absorb this amount of CO2 in 1 day 🌳!") }
          it { expect(page).to have_content("That's the same as charging 1381 smart phones 📱!") }
          it { expect(page).to have_content("That's the same as 2 meat dinners 🍲!") }
          it { expect(page).to have_content("That's the same as 5 veggie dinners 🥗!") }
          it { expect(page).to have_content("That's the same as 249 hours of TV 📺!") }
          it { expect(page).to have_content("That's the same as playing 50 hours of computer games 🎮!") }
          it { expect(page).to_not have_content("That's Carbon Neutral 🌳!") }

          it { expect(page).to have_content("5 pupils and staff included in this survey generated 2.29kg carbon by travelling to school") }
          it { expect(page).to have_content("20% walked or cycled, generating zero CO2") }
          it { expect(page).to have_content("20% travelled by public transport") }
          it { expect(page).to have_content("20% used park and stride") }
          it { expect(page).to have_content("20% travelled by car") }

          it { expect(page).to have_css('#transport_surveys_pie') }

          it "displays a table of transport type results" do
            rows = [['Walking and cycling', 1, '20%'], ['Car', 1, '20%'], ['Public transport', 1, '20%'], ['Park and stride', 1, '20%'], ['Other', 1, '20%']]
            within('table') do
              rows.each do |row|
                expect(page).to have_selector(:table_row, cols.zip(row).to_h)
              end
            end
          end
        end
      end
    end
  end

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
            it { expect(page).to have_content('No surveys have been completed yet') }
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
              expect(page).to have_content(nice_date_times(transport_survey_response.surveyed_at, localtime: true))
            end

            context "and deleting response" do
              before(:each) do
                within('table') do
                  click_link('Delete')
                end
              end
              it { expect(page).to have_content("Transport survey response was successfully removed") }
              it "removes response" do
                expect(page).to_not have_content(nice_date_times(transport_survey_response.surveyed_at, localtime: true))
              end
            end

            it "displays a link to download responses" do
              expect(page).to have_link('Download responses')
            end

            context "and downloading responses" do
              before do
                click_link('Download responses')
              end
              it "shows csv contents" do
                expect(page.body).to eq transport_survey.responses.to_csv
              end
              it "has csv content type" do
                expect(response_headers['Content-Type']).to eq 'text/csv'
              end
              it "has expected file name" do
                expect(response_headers['Content-Disposition']).to include("energy-sparks-transport-survey-#{school.slug}-#{transport_survey.run_on}.csv")
              end
            end
          end

          context "and deleting transport survey" do
            before(:each) do
              within('table') do
                click_link('Delete')
              end
            end
            it { expect(page).to have_content("Transport survey was successfully removed") }
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
        let!(:transport_survey_response) { create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type) }

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

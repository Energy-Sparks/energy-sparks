require 'rails_helper'

describe 'TransportSurveys', type: :system, include_application_helper: true do
  let!(:school)            { create(:school, :with_school_group) }
  let!(:transport_type)    { create(:transport_type, category: :car, can_share: true) }

  describe 'Transport survey results page' do
    describe 'as a public user with read only access' do
      let(:transport_survey) { create(:transport_survey, school: school) }
      let(:cat_cols) { ['Transport category', 'Total pupils & staff', 'Percentage pupils & staff'] }
      let(:car_cols) { ['Time travelled by car', 'Total pupils & staff'] }

      context 'with no results' do
        before do
          visit school_transport_survey_path(school, transport_survey)
        end

        it { expect(page).to have_content('No responses have been collected') }
      end

      context 'with a zero carbon result' do
        before do
          transport_type = create(:transport_type, category: 'walking_and_cycling', kg_co2e_per_km: 0)
          create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type, passengers: 1, journey_minutes: 5)
          visit school_transport_survey_path(school, transport_survey)
        end

        it { expect(page).to have_content('1 pupil or staff member included in this survey generated 0.0kg carbon by travelling to school') }
        it { expect(page).to have_content("That's Carbon Neutral 🌳!") }
        it { expect(page).to have_content('100% walked or cycled, generating zero CO2') }
        it { expect(page).to have_content('0% travelled by public transport') }
        it { expect(page).to have_content('0% used park and stride') }
        it { expect(page).to have_content('0% travelled by car') }

        it { expect(page).to have_css('#transport_surveys_pie') }

        it 'displays a table of transport type results' do
          within('table#responses_per_category') do
            rows = [['Walking and cycling', 1, '100%'], ['Car', 0, '0%'], ['Public transport', 0, '0%'], ['Park and stride', 0, '0%'], ['Other', 0, '0%']]
            rows.each do |row|
              expect(page).to have_selector(:table_row, cat_cols.zip(row).to_h)
            end
          end
        end

        it { expect(page).to have_content('Breakdown of journeys by car') }
        it { expect(page).to have_content("Persuading people who travel only 5 minutes by car to switch to coming to school by foot or bike is a great first step to reducing the school's carbon footprint from travel.")}

        it 'displays a table of times travelled by car' do
          within 'table#time_travelled_by_car' do
            rows = [['5 minutes', 0], ['10 minutes', 0], ['15 minutes', 0], ['20 minutes', 0], ['30 or more minutes', 0]]
            rows.each do |row|
              expect(page).to have_selector(:table_row, car_cols.zip(row).to_h)
            end
          end
        end
      end

      context 'with a carbon positive result' do
        before do
          categories.each do |cat|
            transport_type = create(:transport_type, category: cat, kg_co2e_per_km: 0.17148)
            create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type, passengers: 1, journey_minutes: journey_minutes)
          end
          visit school_transport_survey_path(school, transport_survey)
        end

        context 'with one result' do
          let(:categories) { [:car] }
          let(:journey_minutes) { 5 }

          it { expect(page).to have_content("That's the same as charging 112 smart phones 📱!") }
          it { expect(page).to have_content("That's the same as 1 veggie dinner 🥗!") }
          it { expect(page).to have_content("That's the same as 56 hours of TV 📺!") }
          it { expect(page).to have_content("That's the same as playing 11 hours of computer games 🎮!") }
          it { expect(page).not_to have_content('would absorb this amount of CO2 in 1 day 🌳!') }
          it { expect(page).not_to have_content('meat dinner') }
          it { expect(page).not_to have_content("That's Carbon Neutral 🌳!") }

          it { expect(page).to have_content('1 pupil or staff member included in this survey generated 0.46kg carbon by travelling to school') }
          it { expect(page).to have_content('0% walked or cycled, generating zero CO2') }
          it { expect(page).to have_content('0% travelled by public transport') }
          it { expect(page).to have_content('0% used park and stride') }
          it { expect(page).to have_content('100% travelled by car') }

          it { expect(page).to have_css('#transport_surveys_pie') }

          it 'displays a table of transport type results' do
            within('table#responses_per_category') do
              rows = [['Walking and cycling', 0, '0%'], ['Car', 1, '100%'], ['Public transport', 0, '0%'], ['Park and stride', 0, '0%'], ['Other', 0, '0%']]
              rows.each do |row|
                expect(page).to have_selector(:table_row, cat_cols.zip(row).to_h)
              end
            end
          end

          it { expect(page).to have_content('Breakdown of journeys by car') }
          it { expect(page).to have_content("Persuading people who travel only 5 minutes by car to switch to coming to school by foot or bike is a great first step to reducing the school's carbon footprint from travel.")}

          it 'displays a table of times travelled by car' do
            within 'table#time_travelled_by_car' do
              rows = [['5 minutes', 1], ['10 minutes', 0], ['15 minutes', 0], ['20 minutes', 0], ['30 or more minutes', 0]]
              rows.each do |row|
                expect(page).to have_selector(:table_row, car_cols.zip(row).to_h)
              end
            end
          end
        end

        context 'with one result per category' do
          let(:categories) { [:car, :walking_and_cycling, :public_transport, :park_and_stride, nil] }
          let(:journey_minutes) { 5 }

          it { expect(page).to have_content('1 tree would absorb this amount of CO2 in 1 day 🌳!') }
          it { expect(page).to have_content("That's the same as charging 558 smart phones 📱!") }
          it { expect(page).to have_content("That's the same as 2 meat dinners 🍲!") }
          it { expect(page).to have_content("That's the same as 5 veggie dinners 🥗!") }
          it { expect(page).to have_content("That's the same as 279 hours of TV 📺!") }
          it { expect(page).to have_content("That's the same as playing 56 hours of computer games 🎮!") }
          it { expect(page).to have_no_content("That's Carbon Neutral 🌳!") }

          it { expect(page).to have_content('5 pupils and staff included in this survey generated 2.29kg carbon by travelling to school') }
          it { expect(page).to have_content('20% walked or cycled, generating zero CO2') }
          it { expect(page).to have_content('20% travelled by public transport') }
          it { expect(page).to have_content('20% used park and stride') }
          it { expect(page).to have_content('20% travelled by car') }

          it { expect(page).to have_css('#transport_surveys_pie') }

          it 'displays a table of transport type results' do
            rows = [['Walking and cycling', 1, '20%'], ['Car', 1, '20%'], ['Public transport', 1, '20%'], ['Park and stride', 1, '20%'], ['Other', 1, '20%']]
            within 'table#responses_per_category' do
              rows.each do |row|
                expect(page).to have_selector(:table_row, cat_cols.zip(row).to_h)
              end
            end
          end

          it { expect(page).to have_content('Breakdown of journeys by car') }
          it { expect(page).to have_content("Persuading people who travel only 5 minutes by car to switch to coming to school by foot or bike is a great first step to reducing the school's carbon footprint from travel.")}

          it 'displays a table of times travelled by car' do
            within 'table#time_travelled_by_car' do
              rows = [['5 minutes', 1], ['10 minutes', 0], ['15 minutes', 0], ['20 minutes', 0], ['30 or more minutes', 0]]
              rows.each do |row|
                expect(page).to have_selector(:table_row, car_cols.zip(row).to_h)
              end
            end
          end
        end
      end
    end
  end

  describe 'Abilities' do
    # admin / group admin / group manager / school admin / staff - can manage Transport Surveys, Transport Survey Responses
    # pupil - as above except deleting Surveys and Transport Survey Responses
    # public user - read access only Surveys (but not the start page or responses)

    managing_user_types = [:admin, :group_admin, :group_manager, :school_admin, :staff]
    surveying_user_types = managing_user_types + [:pupil]

    surveying_user_types.each do |user_type|
      describe "as a #{user_type} user who can carry out surveys" do
        let(:user) { create(user_type) }

        before do
          if user.group_admin?
            user.school_group = school.school_group
          elsif user.group_manager?
            school.project_groups << user.school_group
          else
            user.school = school
          end

          sign_in(user)
        end

        context 'when viewing the start page' do
          before do
            visit start_school_transport_surveys_path(school)
          end

          it { expect(page).to have_content('Today\'s travel to school survey') }
          it { expect(page).not_to have_link('Survey today') }
          it { expect(page).to have_content('Javascript must be enabled to use this functionality') }
          it { expect(page).to have_link('View all transport surveys') }
          it { expect(page).not_to have_css('#survey_nav') }

          context 'when attempting to start a survey for a different school' do
            before do
              visit start_school_transport_surveys_path(create(:school, :with_school_group, :with_project))
            end

            it 'limits access' do
              expect(page).not_to have_content('Today\'s travel to school survey') unless user.admin?
            end
          end

          context "when clicking the 'View all transport surveys' button" do
            before do
              click_link 'View all transport surveys'
            end

            it { expect(page).to have_content('No surveys have been completed yet') }
          end
        end
      end
    end

    managing_user_types.each do |user_type|
      describe "as a #{user_type} user who can delete surveys and manage & delete responses" do
        let!(:user) { create(user_type) }

        before do
          if user.group_user?
            user.school_group = school.school_group
          else
            user.school = school
          end

          sign_in(user)
        end

        let!(:transport_survey) { create(:transport_survey, school: school) }
        let!(:transport_survey_response) { create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type) }

        context 'when viewing transport surveys index' do
          before do
            visit school_transport_surveys_path(school)
          end

          it 'shows created transport survey' do
            expect(page).to have_content(nice_dates(transport_survey.run_on))
          end

          it 'shows view results button' do
            expect(page).to have_link('View results')
          end

          it 'shows manage button' do
            expect(page).to have_link('Manage')
          end

          it 'shows delete button' do
            expect(page).to have_link('Delete')
          end

          context 'when managing responses' do
            before do
              within('table') do
                click_link('Manage')
              end
            end

            it 'shows results' do
              within('table') do
                expect(page).to have_content('Survey time')
              end
            end

            it 'displays added response' do
              expect(page).to have_content(nice_date_times(transport_survey_response.surveyed_at, localtime: true))
            end

            context 'when deleting response' do
              before do
                within('table') do
                  click_link('Delete')
                end
              end

              it { expect(page).to have_content('Transport survey response was successfully removed') }

              it 'removes response' do
                expect(page).not_to have_content(nice_date_times(transport_survey_response.surveyed_at, localtime: true))
              end
            end

            it 'displays a link to download responses' do
              expect(page).to have_link('Download responses')
            end

            context 'when downloading responses' do
              before do
                click_link('Download responses')
              end

              it 'shows csv contents' do
                expect(page.body).to eq transport_survey.responses.to_csv
              end

              it 'has csv content type' do
                expect(response_headers['Content-Type']).to eq 'text/csv'
              end

              it 'has expected file name' do
                expect(response_headers['Content-Disposition']).to include("energy-sparks-transport-survey-#{school.slug}-#{transport_survey.run_on}.csv")
              end
            end
          end

          context 'when deleting transport survey' do
            before do
              within('table') do
                click_link('Delete')
              end
            end

            it { expect(page).to have_content('Transport survey was successfully removed') }

            it 'removes transport survey' do
              expect(page).not_to have_content(nice_dates(transport_survey.run_on))
            end
          end
        end
      end
    end

    describe 'as a pupil who cannot delete transport surveys or manage responses' do
      let!(:pupil) { create(:pupil, school: school)}
      let!(:transport_survey) { create(:transport_survey, school: school) }
      let!(:transport_survey_response) { create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type) }

      before do
        sign_in(pupil)
      end

      context 'when viewing transport surveys index' do
        before do
          visit school_transport_surveys_path(school)
        end

        it 'shows created transport survey' do
          expect(page).to have_content(nice_dates(transport_survey.run_on))
        end

        it 'shows surveying link' do
          expect(page).to have_link('Start surveying today')
        end

        it 'shows view results button' do
          expect(page).to have_link('View results')
        end

        it "doesn't show manage button" do
          expect(page).not_to have_link('Manage')
        end

        it "doesn't show survey delete button" do
          expect(page).not_to have_link('Delete')
        end

        context 'when viewing results' do
          before do
            click_link('View results')
          end

          it 'shows results page' do
            expect(page).to have_css('#transport_surveys_pie')
          end

          it "doesn't show link to manage responses" do
            expect(page).not_to have_link('Manage responses')
          end

          it 'shows surveying links' do
            expect(page).not_to have_link('Start surveying today')
            expect(page).to have_link('Survey today')
          end

          it 'shows link to View all transport surveys' do
            expect(page).to have_link('View all transport surveys')
          end
        end
      end
    end

    describe 'as a public user with read only access' do
      context 'when viewing the start page' do
        before do
          visit start_school_transport_surveys_path(school)
        end

        it { expect(page).not_to have_content('Travel to School Surveys') }
      end

      context 'when viewing transport surveys index' do
        let!(:transport_survey) { create(:transport_survey, school: school) }
        let!(:transport_survey_response) { create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type) }

        before do
          visit school_transport_surveys_path(school)
        end

        it 'shows created transport survey' do
          expect(page).to have_content(nice_dates(transport_survey.run_on))
        end

        it 'shows view results button' do
          expect(page).to have_link('View results')
        end

        it "doesn't show surveying link" do
          expect(page).not_to have_link('Start surveying today')
          expect(page).not_to have_link('Survey today')
        end

        it "doesn't show survey delete button" do
          expect(page).not_to have_link('Delete')
        end

        it "doesn't show manage button" do
          expect(page).not_to have_link('Manage')
        end

        context 'when viewing results' do
          before do
            click_link('View results')
          end

          it 'shows results page' do
            expect(page).to have_css('#transport_surveys_pie')
          end

          it "doesn't show link to Survey today" do
            expect(page).not_to have_link('Survey today')
          end

          it "doesn't show link to Manage responses" do
            expect(page).not_to have_link('Manage responses')
          end
        end
      end
    end
  end
end

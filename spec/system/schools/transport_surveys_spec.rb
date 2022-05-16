require 'rails_helper'

describe 'TransportSurveys', type: :system do

  let!(:school)            { create(:school, :with_school_group) }
  let!(:transport_type)    { create(:transport_type, can_share: true) }

  describe "Survey app" do

    describe "as a pupil who can carry out surveys" do
      let(:user) { create(:pupil, school: school) }

      before(:each) do
        sign_in(user)
      end

      context "viewing the start page" do
        before(:each) do
          visit start_school_transport_surveys_path(school)
        end

        context "when javascript is not enabled" do
          it { expect(page).to have_content('Javascript must be enabled to use this functionality.') }
        end

        context "when javascript is enabled", js: true do
          it { expect(page).to have_button('Launch survey app') }

          context "launching the app" do
            before(:each) do
              click_button('Launch survey app')
            end

            let(:weather) { TransportSurveyResponse.weather_symbols[:rain] }

            it { expect(page).to have_content('Please select today\'s weather') }
            it { expect(page).to have_link(weather) }

            context "selecting the weather" do
              before(:each) do
                click_link weather
              end

              let(:time) { TransportSurveyResponse.journey_minutes_options.last }
              it { expect(page).to have_content('Time: How many minutes did your journey take in total?') }
              it { expect(page).to have_link(time.to_s) }
              it { expect(page).to_not have_button('Back') }

              context "selecting a time" do
                before(:each) do
                  click_link time.to_s
                end

                it { expect(page).to have_content('Transport: What mode of transport did you use to get to school?') }
                it { expect(page).to have_link(transport_type.image) }
                it { expect(page).to have_button('Back') }

                context "selecting a transport type" do
                  before(:each) do
                    click_link transport_type.image
                  end

                  it { expect(page).to have_content('Pupil Passengers: How many pupils from school shared this mode of transport (including you)?') }
                  let(:passengers) { TransportSurveyResponse.passengers_options.last.to_i }
                  let(:passengers_link) { TransportSurveyResponse.passenger_symbol * passengers }

                  context "selecting passengers" do
                    before(:each) do
                      click_link(passengers_link)
                    end

                    it { expect(page).to have_content('Confirm your selection') }
                    it "displays survey selection summary" do # bunched these up for test speed
                      expect(page).to have_content(time)
                      expect(page).to have_content(transport_type.image)
                      expect(page).to have_content(passengers)
                    end
                    it { expect(page).to have_button('Confirm') }
                    it { expect(page).to have_button('Back') }

                    context "confirming selection" do
                      before(:each) do
                        click_button("Confirm")
                      end
                      let(:carbon) { ((((transport_type.speed_km_per_hour * time) / 60) * transport_type.kg_co2e_per_km) / passengers).round(3) }

                      it "displays carbon summary" do
                        expect(page).to have_content("For your #{time} minute journey to school by #{transport_type.image} #{transport_type.name} for #{passengers} pupil(s).")
                        expect(page).to have_content("You used #{carbon}kg of carbon each!")
                        expect(find("#display-carbon-equivalent")).to_not be_blank #the content of this is random, so this is as far as it can be tested without getting too complex
                      end
                      it { expect(page).to have_button('Finish & save results 1') }

                      context "Saving results" do
                        before(:each) do
                          accept_alert do
                            click_button("Finish & save results 1")
                          end
                        end

                        # PAGE CONTENT WILL CHANGE SHORTLY
                        it { expect(page).to have_content("Responses for: #{Date.today}") }
                        it "displays added response" do
                          expect(page).to have_content(weather)
                          expect(page).to have_content(time)
                          expect(page).to have_content(transport_type.name)
                          expect(page).to have_content(passengers)
                        end
                      end
                    end
                  end
                end
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

          it { expect(page).to have_content('Travel to School Surveys') }
          it { expect(page).to have_content("Surveying on #{Date.today}") }
          it { expect(page).to have_content('Javascript must be enabled to use this functionality.') }
          it { expect(page).to have_link('View survey responses by date') }

          context "and clicking the 'View survey responses by date' button" do
            before(:each) do
              click_link 'View survey responses by date'
            end

            it { expect(page).to have_content('Travel to School Surveys') }

          end
        end
      end
    end

    MANAGING_USER_TYPES.each do |user_type|
      describe "as a #{user_type} user who can delete surveys and responses" do
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
              click_link("#{transport_survey.run_on}")
            end

            it "lists responses" do
              expect(page).to have_content("Responses for: #{transport_survey.run_on}")
            end

            it "displays added response" do
              expect(page).to have_content(transport_survey_response.run_identifier)
            end

            context "and deleteing response" do
              before(:each) do
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
          expect(page).to have_link('Start a travel to school survey')
        end

        it "doesn't show survey delete button" do
          expect(page).to_not have_link('Delete')
        end

        context "and viewing responses" do
          before(:each) do
            click_link("#{transport_survey.run_on}")
          end

          it "shows link to collect more responses" do
            expect(page).to have_link('Collect more responses')
          end

          it "shows link to View survey responses by date" do
            expect(page).to have_link('View survey responses by date')
          end

          it "doesn't show delete link" do
            expect(page).to_not have_link('Delete')
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
          expect(page).to have_content("#{transport_survey.run_on}")
        end

        it "doesn't show surveying link" do
          expect(page).to_not have_link('Start a travel to school survey')
        end

        it "doesn't show survey delete button" do
          expect(page).to_not have_link('Delete')
        end

        context "and viewing responses" do
          before(:each) do
            click_link("#{transport_survey.run_on}")
          end

          it "doesn't show link to collect more responses" do
            expect(page).to_not have_link('Collect more responses')
          end

          it "shows link to View responses by date" do
            expect(page).to have_link('View survey responses by date')
          end

          it "doesn't show delete link" do
            expect(page).to_not have_link('Delete')
          end
        end
      end
    end
  end

end

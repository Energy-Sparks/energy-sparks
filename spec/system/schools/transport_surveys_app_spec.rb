require 'rails_helper'

describe 'TransportSurveys - App', type: :system do

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

              it { expect(page).to have_content('Sharing: Are you recording this journey for a single pupil or a family or group?') }
              it { expect(page).to_not have_button('Back') }
              let(:passengers) { TransportSurveyResponse.passengers_options.last.to_i }
              let(:passengers_link) { TransportSurveyResponse.passenger_symbol * passengers }

              context "selecting passengers" do
                before(:each) do
                  click_link(passengers_link)
                end

                let(:time) { TransportSurveyResponse.journey_minutes_options.last }
                it { expect(page).to have_content('Time: How many minutes did your journey take in total?') }
                it { expect(page).to have_link(time.to_s) }
                it { expect(page).to have_button('Back') }

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
                        expect(page).to have_content("For your #{time} minute journey to school by #{transport_type.image} #{transport_type.name} for #{passengers} #{'pupil'.pluralize(passengers)}.")
                        expect(page).to have_content("You used #{carbon}kg of carbon each!")
                        expect(find("#display-carbon-equivalent")).to_not be_blank #the content of this is random, so this is as far as it can be tested without getting too complex
                      end
                      it { expect(page).to have_button('Finish & save results 1') }
                      it { expect(page).to_not have_button('Back') }

                      context "Saving results" do
                        before(:each) do
                          click_button("Finish & save results 1")
                        end

                        it { expect(page).to have_css('#transport_surveys_pie') }
                        it { expect(page).to have_content(Date.today.to_s(:es_full)) }
                        it { expect(page).to have_content("#{passengers} pupils") }
                        it { expect(page).to_not have_link("Manage responses") }
                      end
                    end
                  end
                end
              end
            end
            context "when there is nothing to save" do
              before(:each) do
                click_button("Finish & save results 0")
              end
              it { expect(page).to have_content("Nothing to save - please collect some survey responses first!") }
            end
          end
        end
      end
    end
  end
end

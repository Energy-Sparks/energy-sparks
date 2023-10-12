require 'rails_helper'

RSpec.describe "school adult dashboard", type: :system do
  let(:school_name)         { 'Oldfield Park Infants' }
  let!(:school_group)       { create(:school_group, name: 'School Group')}
  let!(:school)             { create(:school, name: school_name, latitude: 51.34062, longitude: -2.30142)}

  context 'as a guest user' do
    context 'and school is data-enabled' do
      describe 'serves a holding page until data is cached' do
        before(:each) do
          allow(AggregateSchoolService).to receive(:caching_off?).and_return(false, true)
          allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
        end

        #non-javascript version of test to check that right template is delivered
        context 'displays the holding page template' do
          it 'renders a loading page' do
            visit school_path(school)
            expect(page).to have_content("Energy Sparks is processing all of this school's data to provide today's analysis")
            expect(page).to have_content("Once we've finished, we will re-direct you to the school dashboard")
          end
        end

        context 'with a successful ajax load', js: true do
          it 'renders a loading page and then back to the dashboard page on success' do
            visit school_path(school)

            within('.dashboard-school-title') do
              expect(page).to have_content(school.name)
            end
            # if redirect fails it will still be processing
            expect(page).to_not have_content('processing')
            expect(page).to_not have_content("we're having trouble processing your energy data today")
          end
        end

        context 'with an ajax loading error', js: true do
          before(:each) do
            allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_raise(StandardError, 'It went wrong')
          end

          it 'shows an error message', errors_expected: true do
            visit school_path(school)
            expect(page).to have_content("we're having trouble processing your energy data today")
          end
        end
      end
    end
    context 'and school is not data-enabled' do
      before(:each) do
        school.update!(data_enabled: false)
        visit school_path(school)
      end
      describe 'it does not show a loading page' do
        before(:each) do
          allow(AggregateSchoolService).to receive(:caching_off?).and_return(false)
          allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
        end

        it 'and redirects to pupil dashboard' do
          visit school_path(school)
          expect(page).to_not have_content("Energy Sparks is processing all of this school's data to provide today's analysis")
          expect(page).to have_content("No activities completed, make a start!")
        end
      end
    end
  end

  context 'with invisible school' do
    let!(:school_invisible)       { create(:school, name: 'Invisible School', visible: false, school_group: school_group)}

    context "as guest user" do
      it 'does not show invisible school or the group' do
        visit root_path
        click_on('View schools')
        expect(page.has_content?(school_name)).to be true
        expect(page.has_content?('Invisible School')).to_not be true
        expect(page.has_content?('School Group')).to_not be true
      end

      it 'prompts user to login when viewing' do
        visit school_path(school_invisible)
        expect(page.has_content?('You are not authorized to access this page')).to be true
      end

      context 'when also not data enabled' do
        it 'does not raise a double render error' do
          school_invisible.update(data_enabled: false)
          visit school_path(school_invisible)
          expect(page.has_content?('You are not authorized to access this page')).to be true
        end
      end
    end

    context 'as admin' do
      let!(:admin) { create(:admin)}

      before(:each) do
        sign_in(admin)
        visit root_path
        click_on('View schools')
      end

      it 'does show invisible school, but not the group' do
        expect(page.has_content?(school_name)).to be true
        expect(page.has_content?('Not visible schools')).to be true
        expect(page.has_content?('Invisible School')).to be true
        expect(page.has_content?('School Group')).to_not be true
      end

      it 'shows school' do
        visit school_path(school_invisible)
        expect(page.has_link?("Pupil dashboard")).to be true
        expect(page.has_content?(school_invisible.name)).to be true
      end
    end
  end

  context 'non-public school' do
    let!(:non_public_school) { create(:school, name: 'Non-public School', visible: true, public: false, school_group: school_group)}

    context 'as unknown user' do
      it 'is listed on school page' do
        visit root_path
        click_on('View schools')

        expect(page.has_content?(non_public_school.name)).to be true
        expect(page.has_content?('School Group')).to be true
      end

      it 'prompts user to login when viewing' do
        visit school_path(non_public_school)
        expect(page.has_content?('This school has disabled public access')).to be true
      end
    end

    context 'as staff' do
      let!(:school_admin) { create(:school_admin, school: non_public_school) }

      before(:each) do
        sign_in(school_admin)
      end

      it 'displays the school page' do
        visit school_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link("Compare schools")
      end

      it 'redirects away user from the /private page' do
        visit school_private_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link("Compare schools")
      end
    end

    context 'as a user in the same school group' do
      let!(:school_in_same_group)   { create(:school, name: 'Same Group School', visible: true, school_group: school_group)}
      let!(:other_admin)            { create(:school_admin, school: school_in_same_group) }

      before(:each) do
        sign_in(other_admin)
      end

      it 'displays the school page' do
        visit school_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link("Compare schools")
      end
    end

    context 'as a unrelated school user' do
      let!(:other_admin)    { create(:school_admin) }
      before(:each) do
        sign_in(other_admin)
      end

      it 'prompts user to login when viewing' do
        visit school_path(non_public_school)
        expect(page.has_content?('This school has disabled public access')).to be true
      end
    end
  end
end

require 'rails_helper'

describe 'School setup review', :include_application_helper, type: :system do
  let(:school_group) { create(:school_group, default_issues_admin_user: create(:admin)) }
  let!(:school) { create(:school, school_group: school_group) }

  shared_examples 'a prompt is generated' do
    it 'with a message, status and link' do
      expect(page).to have_css("##{section}")
      within("##{section}") do
        expect(page).to have_css("##{id}")
        expect(page).to have_css("div.#{status}")
        within("##{id}") do
          expect(page).to have_content(msg)
          expect(page).to have_link(href: link)
        end
      end
    end
  end

  shared_examples 'an error is displayed' do
    it_behaves_like 'a prompt is generated' do
      let(:section) { 'errors' }
    end
  end

  shared_examples 'a warning is displayed' do
    it_behaves_like 'a prompt is generated' do
      let(:section) { 'warnings' }
    end
  end

  describe 'as other user' do
    before do
      sign_in(create(:staff, school: school))
      visit school_review_path(school)
    end

    it_behaves_like 'the user is not authorised'
  end

  describe 'as an admin' do
    let(:admin) { create(:admin) }

    before do
      sign_in(admin)
      visit school_review_path(school)
    end

    context 'when school has errors' do
      context 'with no pupils' do
        let!(:school) { create(:school, school_group: school_group, number_of_pupils: nil) }

        it_behaves_like 'an error is displayed' do
          let(:id) { 'pupils' }
          let(:status) { :negative }
          let(:msg) { 'Missing pupil numbers' }
          let(:link) { edit_school_path(school) }
        end
      end

      context 'with no floor area' do
        let!(:school) { create(:school, school_group: school_group, floor_area: nil) }

        it_behaves_like 'an error is displayed' do
          let(:id) { 'floor-area' }
          let(:status) { :negative }
          let(:msg) { 'Missing floor area' }
          let(:link) { edit_school_path(school) }
        end
      end

      context 'with no active meters' do
        it_behaves_like 'an error is displayed' do
          let(:id) { 'active-meters' }
          let(:status) { :negative }
          let(:msg) { 'No active meters' }
          let(:link) { school_meters_path(school) }
        end
      end

      context 'with no active users' do
        it_behaves_like 'an error is displayed' do
          let(:id) { 'active-users' }
          let(:status) { :negative }
          let(:msg) { 'No active users' }
          let(:link) { school_users_path(school) }
        end
      end

      context 'with no solar' do
        let!(:school) { create(:school, school_group: school_group, indicated_has_solar_panels: true) }

        it_behaves_like 'an error is displayed' do
          let(:id) { 'solar' }
          let(:status) { :negative }
          let(:msg) { 'No solar panels configured, but school has said they have solar' }
          let(:link) { school_meters_path(school) }
        end
      end

      context 'with no storage heating' do
        let!(:school) { create(:school, school_group: school_group, indicated_has_storage_heaters: true) }

        it_behaves_like 'a warning is displayed' do
          let(:id) { 'storage-heaters' }
          let(:status) { :neutral }
          let(:msg) { 'No storage heaters configured' }
          let(:link) { school_meters_path(school) }
        end
      end

      context 'with no alert contacts' do
        let!(:school) { create(:school, school_group: school_group, indicated_has_storage_heaters: true) }
        let!(:school_admin) { create(:school_admin, school: school) }

        it_behaves_like 'a warning is displayed' do
          let(:id) { 'alert-contacts' }
          let(:status) { :neutral }
          let(:msg) { 'No users are subscribed to alerts' }
          let(:link) { school_users_path(school) }
        end
      end

      context 'with large pupil numbers' do
        let!(:school) { create(:school, school_group: school_group, number_of_pupils: 10000) }
        let!(:school_admin) { create(:school_admin, school: school) }

        it_behaves_like 'a warning is displayed' do
          let(:id) { 'number-of-pupils' }
          let(:status) { :neutral }
          let(:msg) { 'Does 10000 pupils seem correct for this size of school?' }
          let(:link) { edit_school_path(school) }
        end
      end

      context 'with large floor area' do
        let!(:school) { create(:school, school_group: school_group, floor_area: 100000, number_of_pupils: 10) }
        let!(:school_admin) { create(:school_admin, school: school) }

        it_behaves_like 'a warning is displayed' do
          let(:id) { 'size-of-buildings' }
          let(:status) { :neutral }
          let(:msg) { 'Does 100000.0 m2 seem correct for this size of school?' }
          let(:link) { edit_school_path(school) }
        end
      end

      context 'with default school times' do
        let!(:school) { create(:school, school_group: school_group, floor_area: 100000, number_of_pupils: 10) }

        before do
          SchoolTime.days.each do |day, day_number|
            school.school_times.create(day: day) if day_number <= 4
          end
        end

        it_behaves_like 'a warning is displayed' do
          let(:id) { 'school-times' }
          let(:status) { :neutral }
          let(:msg) { 'The school is still using our default opening and closing times' }
          let(:link) { edit_school_times_path(school) }
        end

        it_behaves_like 'a warning is displayed' do
          let(:id) { 'community-use' }
          let(:status) { :neutral }
          let(:msg) { 'The school has not set any community use periods' }
          let(:link) { edit_school_times_path(school) }
        end
      end

      context 'with no consent' do
        it_behaves_like 'an error is displayed' do
          let(:id) { 'no-consent' }
          let(:status) { :negative }
          let(:msg) { 'We do not have consent from the school to publish their data' }
          let(:link) { new_admin_school_consent_request_path(school) }
        end
      end

      context 'with pending bill request' do
        let!(:school) { create(:school, school_group: school_group, bill_requested: true) }

        it_behaves_like 'a warning is displayed' do
          let(:id) { 'pending-bill' }
          let(:status) { :neutral }
          let(:msg) { 'We are waiting for a bill from this school' }
          let(:link) { school_consent_documents_path(school) }
        end
      end
    end
  end
end

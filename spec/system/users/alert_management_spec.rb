require 'rails_helper'

RSpec.describe 'User alert management', :include_application_helper do
  shared_examples 'an alert management page' do
    it 'lists all schools' do
      schools.each do |school|
        expect(page).to have_link(school.name, href: school_path(school))
        expect(page).to have_link(I18n.t('common.labels.view_alerts'), href: alerts_school_advice_path(school))
      end
    end

    it 'displays clusters if found' do
      cluster = create(:school_group_cluster)
      schools.first.update!(school_group_cluster: cluster)
      refresh
      expect(page).to have_content(cluster.name)
    end

    context 'when user has an alert', :js do
      let!(:contact) do
        Contact.create(
          user_id: user.id,
          school_id: schools.first.id,
          name: user.display_name,
          email_address: user.email,
          staff_role: user.staff_role
        )
      end

      it 'allows user to unsubscribe' do
        refresh
        accept_confirm do
          find_link(I18n.t('common.labels.unsubscribe'), match: :first).click
        end
        expect(page).to have_content(I18n.t('users.contacts.create.unsubscribed'))
        expect(user.contacts).to be_empty
      end
    end

    context 'with no alerts', :js do
      it 'allows user to subscribe' do
        accept_confirm do
          find_link(I18n.t('common.labels.subscribe'), match: :first).click
        end
        expect(page).to have_content(I18n.t('users.contacts.create.subscribed'))
        expect(user.contacts).not_to be_empty
      end
    end
  end

  context 'when logged in' do
    before do
      sign_in(user)
      visit user_path(user)
    end

    context 'with a school admin' do
      let(:user) { create(:school_admin) }

      before do
        within('#profile-page-navigation') do
          click_on(I18n.t('users.show.manage_alerts'))
        end
      end

      it_behaves_like 'an account page with navigation'
      it_behaves_like 'an alert management page' do
        let(:schools) { [user.school] }
      end
    end

    context 'with a staff user' do
      let(:user) { create(:staff) }

      before do
        within('#profile-page-navigation') do
          click_on(I18n.t('users.show.manage_alerts'))
        end
      end

      it_behaves_like 'an account page with navigation'
      it_behaves_like 'an alert management page' do
        let(:schools) { [user.school] }
      end
    end

    context 'with a cluster admin' do
      let(:user) { create(:school_admin, :with_cluster_schools) }

      before do
        within('#profile-page-navigation') do
          click_on(I18n.t('users.show.manage_alerts'))
        end
      end

      it_behaves_like 'an account page with navigation'
      it_behaves_like 'an alert management page' do
        let(:schools) { user.cluster_schools }
      end
    end

    context 'with a group admin' do
      let!(:user) { create(:group_admin, school_group: create(:school_group, :with_active_schools)) }

      before do
        within('#profile-page-navigation') do
          click_on(I18n.t('users.show.manage_alerts'))
        end
      end

      it_behaves_like 'an account page with navigation'
      it_behaves_like 'an alert management page' do
        let(:schools) { user.school_group.schools.visible }
      end

      context 'with an extra alert' do
        let!(:contact) { create(:contact_with_name_email_phone, user: user) }

        it 'displays the extra school' do
          refresh
          expect(page).to have_content(contact.school.name)
        end
      end
    end

    context 'with an admin' do
      let(:user) { create(:admin) }

      it_behaves_like 'an account page with navigation', admin: true

      it 'does not show link to my alerts' do
        expect(page).not_to have_link(I18n.t('users.show.manage_alerts'), href: user_contacts_path(user))
      end

      context 'when viewing another user' do
        let(:school_admin) { create(:school_admin) }

        before do
          visit user_path(school_admin)
          within('#profile-page-navigation') do
            click_on(I18n.t('users.show.manage_alerts'))
          end
        end

        it_behaves_like 'an account page with navigation' do
          let(:user) { school_admin}
        end

        it_behaves_like 'an alert management page' do
          let(:user) { school_admin }
          let(:schools) { [user.school] }
        end
      end
    end
  end
end

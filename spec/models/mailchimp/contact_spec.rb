require 'rails_helper'

describe Mailchimp::Contact do
  shared_examples 'it correctly creates a contact' do |school_user: false, group_admin: false, cluster_admin: false|
    it 'populates the common fields' do
      expect(contact.email_address).to eq user.email
      expect(contact.name).to eq user.name
      expect(contact.contact_source).to eq 'User'
      expect(contact.confirmed_date).to eq user.confirmed_at.to_date.iso8601
      expect(contact.locale).to eq user.preferred_locale
    end

    it 'populates school user fields', if: school_user do
      expect(contact.user_role).to eq user.role.humanize
      expect(contact.staff_role).to eq user.staff_role.title
      expect(contact.alert_subscriber).to eq 'No'
      expect(contact.school_status).to eq 'Active'
      expect(contact.school).to eq user.school.name
      expect(contact.school_group).to eq user.school.school_group.name
      expect(contact.country).to eq user.school.country.humanize
      expect(contact.scoreboard).to eq user.school.scoreboard.name
      expect(contact.local_authority).to eq user.school.local_authority_area.name
      expect(contact.region).to eq user.school.region.humanize
    end

    it 'populates cluster admin fields', if: cluster_admin do
      expect(contact.user_role).to eq 'Cluster admin'
      expect(contact.staff_role).to eq user.staff_role.title
      expect(contact.alert_subscriber).to eq 'No'
      expect(contact.school_status).to be_nil
      expect(contact.school).to be_nil
      expect(contact.scoreboard).to eq user.school.school_group.default_scoreboard.name
      expect(contact.school_group).to eq user.school.school_group.name
      expect(contact.local_authority).to be_nil
      expect(contact.region).to be_nil
      expect(contact.country).to eq user.school.school_group.default_country.humanize
    end

    it 'populates group admin fields', if: group_admin do
      expect(contact.user_role).to eq user.role.humanize
      expect(contact.staff_role).to be_nil
      expect(contact.alert_subscriber).to eq 'No'
      expect(contact.school_status).to be_nil
      expect(contact.school).to be_nil
      expect(contact.scoreboard).to eq user.school_group.default_scoreboard.name
      expect(contact.school_group).to eq user.school_group.name
      expect(contact.local_authority).to be_nil
      expect(contact.region).to be_nil
      expect(contact.country).to eq user.school_group.default_country.humanize
    end
  end

  shared_examples 'it adds the interests' do
    it 'preserves the interests' do
      expect(contact.interests.keys).to match_array(interests.keys)
    end
  end

  describe '.from_user' do
    let(:tags) { [] }
    let(:interests) { { 'Newsletter' => true } }

    let(:contact) { described_class.from_user(user, tags: tags, interests: interests) }

    context 'with a school admin' do
      let!(:school) { create(:school, :with_school_group, :with_scoreboard, :with_local_authority, region: :east_midlands, percentage_free_school_meals: 35) }
      let!(:user) { create(:school_admin, school: school) }

      it_behaves_like 'it correctly creates a contact', school_user: true
      it_behaves_like 'it adds the interests'

      it 'populates tags' do
        expect(contact.tags).to contain_exactly('FSM30', user.school.slug)
      end

      context 'with existing interests' do
        let(:interests) { { 'Newsletter' => true, 'Other' => true } }

        it_behaves_like 'it adds the interests'
      end

      context 'with existing non free school meal tags' do
        let(:tags) { ['external support'] }

        it 'preserves the tags' do
          expect(contact.tags).to contain_exactly('external support', 'FSM30', user.school.slug)
        end
      end

      context 'with existing free school meal tags' do
        let(:tags) { ['FSM10'] }

        it 'overwrites the tags' do
          expect(contact.tags).to contain_exactly('FSM30', user.school.slug)
        end
      end

      context 'with archived school' do
        let!(:school) { create(:school, :with_school_group, :with_scoreboard, :with_local_authority, :archived, region: :east_midlands) }

        it 'uses correct status' do
          expect(contact.school_status).to eq 'Archived'
        end
      end

      context 'when subscribed to alerts' do
        let!(:user) { create(:school_admin, :subscribed_to_alerts, school: school) }

        it 'uses correct status' do
          expect(contact.alert_subscriber).to eq 'Yes'
        end
      end
    end

    context 'with a group admin' do
      let!(:user) { create(:group_admin, school_group: create(:school_group, :with_default_scoreboard)) }

      it_behaves_like 'it correctly creates a contact', group_admin: true

      it_behaves_like 'it adds the interests'

      context 'when subscribed to alerts' do
        let!(:user) do
          school_group = create(:school_group, :with_default_scoreboard, :with_active_schools)
          user = create(:group_admin, school_group: school_group)
          user.contacts << create(:contact_with_name_email_phone, school: school_group.schools.first)
          user
        end

        it 'uses correct status' do
          expect(contact.alert_subscriber).to eq 'Yes'
        end
      end
    end

    context 'with a cluster admin' do
      let!(:school) { create(:school, :with_scoreboard, :with_local_authority, region: :east_midlands, percentage_free_school_meals: 35, school_group: create(:school_group, :with_default_scoreboard)) }
      let!(:user) { create(:school_admin, :with_cluster_schools, school: school) }

      it_behaves_like 'it correctly creates a contact', school_user: false, cluster_admin: true

      it_behaves_like 'it adds the interests'

      it 'adds tags for each cluster school' do
        expect(contact.tags).to contain_exactly(user.cluster_schools.map(&:slug))
      end

      context 'when subscribed to alerts' do
        let!(:user) { create(:school_admin, :with_cluster_schools, :subscribed_to_alerts, school: school) }

        it 'uses correct status' do
          expect(contact.alert_subscriber).to eq 'Yes'
        end
      end
    end

    context 'with an admin' do
      let!(:user) { create(:admin) }

      it_behaves_like 'it correctly creates a contact'
      it_behaves_like 'it adds the interests'
    end
  end
end

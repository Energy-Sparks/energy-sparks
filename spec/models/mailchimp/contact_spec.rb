require 'rails_helper'

describe Mailchimp::Contact do
  shared_examples 'it correctly creates a contact' do |school_user: false, group_admin: false, cluster_admin: false|
    it 'populates the common fields' do
      expect(contact.email_address).to eq user.email
      expect(contact.name).to eq user.name
      expect(contact.contact_source).to eq 'User'
      expect(contact.confirmed_date).to eq user.confirmed_at.to_date.iso8601
      expect(contact.locale).to eq user.preferred_locale
      expect(contact.user_status).to eq 'Active'
    end

    it 'populates school user fields', if: school_user do
      expect(contact.user_role).to eq user.role.humanize
      expect(contact.staff_role).to eq user.staff_role.title
      expect(contact.alert_subscriber).to eq 'No'
      expect(contact.school_status).to eq 'Active'
      expect(contact.school_type).to eq school.school_type.humanize
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

    it 'populates school links', if: school_user do
      expect(contact.school_url).to eq "https://energysparks.uk/schools/#{school.slug}"
      expect(contact.school_group_url).to eq "https://energysparks.uk/school_groups/#{school.school_group.slug}"
      expect(contact.scoreboard_url).to eq "https://energysparks.uk/scoreboards/#{school.scoreboard.slug}"
      expect(contact.school_slug).to eq school.slug
      expect(contact.school_group_slug).to eq school.school_group.slug
    end

    it 'populates school group links', if: group_admin do
      expect(contact.school_group_url).to eq "https://energysparks.uk/school_groups/#{user.school_group.slug}"
      expect(contact.scoreboard_url).to eq "https://energysparks.uk/scoreboards/#{user.school_group.default_scoreboard.slug}"
      expect(contact.school_group_slug).to eq user.school_group.slug
    end

    it 'populates school group links', if: cluster_admin do
      expect(contact.school_group_url).to eq "https://energysparks.uk/school_groups/#{school.school_group.slug}"
      expect(contact.scoreboard_url).to eq "https://energysparks.uk/scoreboards/#{user.school.school_group.default_scoreboard.slug}"
      expect(contact.school_group_slug).to eq user.school.school_group.slug
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

      context 'when account is disabled' do
        let!(:user) { create(:school_admin, :subscribed_to_alerts, school: school, active: false) }

        it 'switches user to Organic' do
          expect(contact.contact_source).to eq 'Organic'
        end
      end
    end

    context 'with a group_admin' do
      let!(:user) { create(:group_admin, school_group: create(:school_group, :with_default_scoreboard)) }

      it_behaves_like 'it correctly creates a contact', group_admin: true

      it_behaves_like 'it adds the interests'

      context 'when subscribed to alerts' do
        let!(:user) do
          school_group = create(:school_group, :with_default_scoreboard, :with_active_schools)
          user = create(:group_admin, school_group: school_group)
          user.contacts << create(:contact_with_name_email_phone, school: school_group.assigned_schools.first)
          user
        end

        it 'uses correct status' do
          expect(contact.alert_subscriber).to eq 'Yes'
        end
      end

      context 'when account is disabled' do
        let!(:user) { create(:group_admin, school_group: create(:school_group, :with_default_scoreboard), active: false) }

        it 'switches user to Organic' do
          expect(contact.contact_source).to eq 'Organic'
        end
      end
    end

    context 'with a group_manager' do
      let(:school_group) { create(:school_group, :project_group, :with_default_scoreboard) }
      let!(:user) { create(:group_manager, school_group:) }

      it_behaves_like 'it correctly creates a contact', group_admin: true

      it_behaves_like 'it adds the interests'

      context 'when subscribed to alerts' do
        let!(:user) do
          school_group = create(:school_group, :project_group, :with_default_scoreboard, :with_active_schools)
          user = create(:group_manager)
          user.contacts << create(:contact_with_name_email_phone, school: school_group.assigned_schools.first)
          user
        end

        it 'uses correct status' do
          expect(contact.alert_subscriber).to eq 'Yes'
        end
      end

      context 'when account is disabled' do
        let!(:user) { create(:group_manager, school_group: create(:school_group, :project_group, :with_default_scoreboard), active: false) }

        it 'switches user to Organic' do
          expect(contact.contact_source).to eq 'Organic'
        end
      end
    end

    context 'with a cluster admin' do
      let!(:school) { create(:school, :with_scoreboard, :with_local_authority, region: :east_midlands, percentage_free_school_meals: 35, school_group: create(:school_group, :with_default_scoreboard)) }
      let!(:user) { create(:school_admin, :with_cluster_schools, school: school) }

      it_behaves_like 'it correctly creates a contact', school_user: false, cluster_admin: true

      it_behaves_like 'it adds the interests'

      it 'adds tags for each cluster school' do
        expect(contact.tags).to match_array(user.cluster_schools.map(&:slug))
      end

      context 'when subscribed to alerts' do
        let!(:user) { create(:school_admin, :with_cluster_schools, :subscribed_to_alerts, school: school) }

        it 'uses correct status' do
          expect(contact.alert_subscriber).to eq 'Yes'
        end
      end

      context 'when account is disabled' do
        let!(:user) { create(:school_admin, :with_cluster_schools, school: school, active: false) }

        it 'switches user to Organic' do
          expect(contact.contact_source).to eq 'Organic'
        end
      end
    end

    context 'with an admin' do
      let!(:user) { create(:admin) }

      it_behaves_like 'it correctly creates a contact'
      it_behaves_like 'it adds the interests'
    end
  end

  describe '.from_params' do
    let(:params) do
      {
        email_address: 'person@example.org',
        name: 'John Smith',
        school: 'Some School',
        interests: {
          '4abcd': 'true'
        }
      }
    end

    let(:contact) { described_class.from_params(params) }

    it 'creates a contact' do
      expect(contact.email_address).to eq('person@example.org')
      expect(contact.name).to eq('John Smith')
      expect(contact.school).to eq('Some School')
      expect(contact.contact_source).to eq('Organic')
      expect(contact.interests).to eq({ '4abcd': true })
    end
  end

  describe '.free_school_meal_tags' do
    def expect_fsm_tag(fsm_percentage, expected_tags)
      school = create(:school, percentage_free_school_meals: fsm_percentage)
      expect(described_class.free_school_meal_tags(school)).to eq(expected_tags)
    end

    it 'creates correct tags' do
      expect_fsm_tag(31, ['FSM30'])
      expect_fsm_tag(30, ['FSM30'])
      expect_fsm_tag(29, ['FSM25'])
      expect_fsm_tag(25, ['FSM25'])
      expect_fsm_tag(24, ['FSM20'])
      expect_fsm_tag(20, ['FSM20'])
      expect_fsm_tag(19, ['FSM15'])
      expect_fsm_tag(15, ['FSM15'])
      expect_fsm_tag(14, [])
      expect_fsm_tag(nil, [])
    end
  end

  describe '.default_interests' do
    include_context 'with a stubbed audience manager'

    let(:interests) { Mailchimp::AudienceManager.new.interests('abc') }

    shared_examples 'interests have been selected' do
      subject(:defaults) { described_class.default_interests(interests, user) }

      def expect_all_interests(name_to_id, list, val)
        list.each do |i|
          interest_id = name_to_id[i]
          expect(defaults[interest_id]).to be(val)
        end
      end

      it 'with only expected options as true' do
        name_to_id = interests.to_h { |i| [i.name, i.id] }
        expect_all_interests(name_to_id, selected, true)
        expect_all_interests(name_to_id, name_to_id.keys - selected, false)
      end
    end

    shared_examples 'it maps all the roles correctly' do
      it_behaves_like 'interests have been selected' do
        let(:user) { create(role, staff_role: create(:staff_role, title: 'Business manager'))}
        let(:selected) do
          [
            described_class::GETTING_THE_MOST,
            described_class::LEADERSHIP,
            described_class::TRAINING,
            described_class::TAILORED_ADVICE
          ]
        end
      end

      it_behaves_like 'interests have been selected' do
        let(:user) { create(role, staff_role: create(:staff_role, title: 'Building/site manager or caretaker'))}
        let(:selected) do
          [
            described_class::GETTING_THE_MOST,
            described_class::LEADERSHIP,
            described_class::TRAINING,
            described_class::TAILORED_ADVICE
          ]
        end
      end

      it_behaves_like 'interests have been selected' do
        let(:user) { create(role, staff_role: create(:staff_role, title: 'Governor'))}
        let(:selected) do
          [
            described_class::GETTING_THE_MOST,
            described_class::LEADERSHIP,
            described_class::TRAINING,
            described_class::TAILORED_ADVICE
          ]
        end
      end

      it_behaves_like 'interests have been selected' do
        let(:user) { create(role, staff_role: create(:staff_role, title: 'Teacher or teaching assistant'))}
        let(:selected) do
          [
            described_class::GETTING_THE_MOST,
            described_class::ENGAGING_PUPILS,
            described_class::TRAINING,
            described_class::TAILORED_ADVICE
          ]
        end
      end

      it_behaves_like 'interests have been selected' do
        let(:user) { create(role, staff_role: create(:staff_role, title: 'Headteacher or Deputy Head'))}
        let(:selected) do
          [
            described_class::GETTING_THE_MOST,
            described_class::ENGAGING_PUPILS,
            described_class::LEADERSHIP,
            described_class::TRAINING,
            described_class::TAILORED_ADVICE
          ]
        end
      end

      it_behaves_like 'interests have been selected' do
        let(:user) { create(role, staff_role: create(:staff_role, title: 'Council or MAT staff'))}
        let(:selected) do
          [
            described_class::GETTING_THE_MOST,
            described_class::LEADERSHIP,
            described_class::TRAINING,
            described_class::TAILORED_ADVICE
          ]
        end
      end

      it_behaves_like 'interests have been selected' do
        let(:user) { create(role, staff_role: create(:staff_role, title: 'Parent or volunteer'))}
        let(:selected) do
          [
            described_class::GETTING_THE_MOST,
            described_class::ENGAGING_PUPILS,
            described_class::TRAINING,
            described_class::TAILORED_ADVICE
          ]
        end
      end

      it_behaves_like 'interests have been selected' do
        let(:user) { create(role, staff_role: create(:staff_role, title: 'Public'))}
        let(:selected) do
          [
            described_class::GETTING_THE_MOST,
            described_class::TRAINING,
            described_class::TAILORED_ADVICE
          ]
        end
      end
    end

    context 'with no user' do
      it_behaves_like 'interests have been selected' do
        let(:user) { nil }
        let(:selected) do
          [described_class::GETTING_THE_MOST, described_class::ENGAGING_PUPILS, described_class::LEADERSHIP]
        end
      end
    end

    [:group_admin, :group_manager].each do |role|
      context "with #{role}" do
        it_behaves_like 'interests have been selected' do
          let(:user) { create(role)}
          let(:selected) do
            [
              described_class::GETTING_THE_MOST,
              described_class::ENGAGING_PUPILS,
              described_class::LEADERSHIP,
              described_class::TRAINING,
              described_class::TAILORED_ADVICE
            ]
          end
        end
      end
    end

    context 'with admin' do
      it_behaves_like 'interests have been selected' do
        let(:user) { create(:admin) }
        let(:selected) do
          [Mailchimp::Contact::GETTING_THE_MOST, Mailchimp::Contact::ENGAGING_PUPILS, Mailchimp::Contact::LEADERSHIP]
        end
      end
    end

    context 'with school users' do
      context 'with staff' do
        it_behaves_like 'it maps all the roles correctly' do
          let(:role) { :staff }
        end
      end

      context 'with school admin' do
        it_behaves_like 'it maps all the roles correctly' do
          let(:role) { :school_admin }
        end
      end
    end
  end
end

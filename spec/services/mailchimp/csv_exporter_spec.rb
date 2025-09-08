require 'rails_helper'

describe Mailchimp::CsvExporter do
  include_context 'with a stubbed audience manager'

  subject(:service) do
    described_class.new(add_default_interests: add_default_interests, subscribed: subscribed, nonsubscribed: nonsubscribed, unsubscribed: unsubscribed, cleaned: cleaned)
  end

  let(:add_default_interests) { true }
  let(:subscribed) { [] }
  let(:nonsubscribed) { [] }
  let(:unsubscribed) { [] }
  let(:cleaned) { [] }

  def create_contact(email_address, **fields)
    contact = ActiveSupport::OrderedOptions.new
    contact.email_address = email_address
    fields.each do |keyword, value|
      contact[keyword] = value
    end
    contact
  end

  shared_examples 'it adds interests correctly' do
    it 'adds emails types as a comma-separated list' do
      expect(contact.interests.split(',')).to include 'Getting the most out of Energy Sparks'
    end
  end

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

  context 'when the Mailchimp contacts are Users' do
    let(:subscribed) do
      [create_contact(user.email)]
    end

    let(:contact) do
      service.updated_audience[:subscribed].first
    end

    before do
      service.perform
    end

    context 'with a school admin' do
      let!(:school) { create(:school, :with_school_group, :with_scoreboard, :with_local_authority, default_issues_admin_user: nil, region: :east_midlands, percentage_free_school_meals: 35) }
      let!(:user) { create(:school_admin, school: school) }

      it 'matches the contact' do
        expect(service.updated_audience[:subscribed].length).to eq(1)
      end

      it_behaves_like 'it correctly creates a contact', school_user: true
      it_behaves_like 'it adds interests correctly'

      it 'populates tags' do
        expect(contact.tags.split(',')).to contain_exactly('FSM30', user.school.slug)
      end

      context 'when user is not active' do
        let!(:user) { create(:school_admin, school: school, active: false) }

        it 'does not add any interests' do
          expect(contact.interests).to eq('')
        end
      end

      context 'when not adding in default interests' do
        let(:add_default_interests) { false }

        it 'does not add any interests' do
          expect(contact.interests).to eq('')
        end
      end

      context 'with existing interests' do
        let(:subscribed) do
          [create_contact(user.email, interests: 'Getting the most out of Energy Sparks,Others')]
        end

        it 'preserves the existing interests' do
          expect(contact.interests).to include('Getting the most out of Energy Sparks')
          expect(contact.interests).to include('Others')
        end

        context 'when not adding in the default interests' do
          let(:add_default_interests) { false }

          it 'preserves the existing interests' do
            expect(contact.interests).to include('Getting the most out of Energy Sparks')
            expect(contact.interests).to include('Others')
          end
        end
      end

      context 'with existing non free school meal tags' do
        let(:subscribed) do
          [create_contact(user.email, tags: 'external support')]
        end

        it 'preserves the tags' do
          expect(contact.tags.split(',')).to contain_exactly('external support', 'FSM30', user.school.slug)
        end
      end

      context 'with existing free school meal tags' do
        let(:subscribed) do
          [create_contact(user.email, tags: 'FSM10')]
        end

        it 'overwrites the tags' do
          expect(contact.tags.split(',')).to contain_exactly('FSM30', user.school.slug)
        end
      end

      context 'with mixed case email' do
        let(:subscribed) do
          [create_contact(user.email.upcase)]
        end

        it_behaves_like 'it correctly creates a contact', school_user: true
        it_behaves_like 'it adds interests correctly'
      end

      context 'with archived school' do
        let!(:school) { create(:school, :with_school_group, :with_scoreboard, :with_local_authority, :archived, default_issues_admin_user: nil, region: :east_midlands) }

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

      context 'when user is unsubscribed' do
        let(:unsubscribed) do
          [create_contact(user.email)]
        end
        let(:subscribed) { [] }

        let(:contact) do
          service.updated_audience[:unsubscribed].first
        end

        it 'preserves the category' do
          expect(service.updated_audience[:subscribed].length).to eq(0)
          expect(service.updated_audience[:unsubscribed].length).to eq(1)
        end

        it_behaves_like 'it correctly creates a contact', school_user: true
        it_behaves_like 'it adds interests correctly'
      end
    end

    context 'with a group admin' do
      let!(:user) { create(:group_admin, school_group: create(:school_group, :with_default_scoreboard, default_issues_admin_user: nil)) }

      it_behaves_like 'it correctly creates a contact', group_admin: true
      it_behaves_like 'it adds interests correctly'

      context 'when subscribed to alerts' do
        let!(:user) do
          school_group = create(:school_group, :with_default_scoreboard, :with_active_schools, default_issues_admin_user: nil)
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
      let!(:school) { create(:school, :with_scoreboard, :with_local_authority, region: :east_midlands, percentage_free_school_meals: 35, school_group: create(:school_group, :with_default_scoreboard, default_issues_admin_user: nil)) }
      let!(:user) { create(:school_admin, :with_cluster_schools, school: school) }

      it_behaves_like 'it correctly creates a contact', school_user: false, cluster_admin: true
      it_behaves_like 'it adds interests correctly'

      it 'adds tags for each cluster school' do
        expect(contact.tags.split(',')).to match_array(user.cluster_schools.map(&:slug))
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
      it_behaves_like 'it adds interests correctly'
    end
  end

  context 'when the Mailchimp contacts are not Users' do
    let(:contact) do
      service.updated_audience[:subscribed].first
    end

    before do
      service.perform
    end

    context 'with a post-migration contact' do
      let(:subscribed) do
        [create_contact('user@example.org', name: 'John Smith', staff_role: 'School management', school_group: 'Unity Schools Partnership', school_or_organisation: 'DfE', tags: 'trustee,external support')]
      end

      it_behaves_like 'it adds interests correctly'

      it 'populates the fields correctly' do
        expect(contact.email_address).to eq('user@example.org')
        expect(contact.name).to eq 'John Smith'
        expect(contact.contact_source).to eq 'Organic'
        expect(contact.confirmed_date).to be_nil
        expect(contact.user_role).to be_nil
        expect(contact.locale).to eq 'en'
        expect(contact.tags).to eq 'trustee,external support'
        expect(contact.staff_role).to eq 'School management'
        expect(contact.school).to eq 'DfE'
        expect(contact.school_group).to eq 'Unity Schools Partnership'
      end

      context 'when not adding in default interests' do
        let(:add_default_interests) { false }

        it 'does not add any interests' do
          expect(contact.interests).to eq('')
        end
      end
    end
  end

  context 'when there are Users not in Mailchimp' do
    let(:contact) { service.new_nonsubscribed.first }

    context 'with a school admin' do
      let!(:school) { create(:school, :with_school_group, :with_scoreboard, :with_local_authority, region: :east_midlands, default_issues_admin_user: nil, percentage_free_school_meals: 35) }
      let!(:user) { create(:school_admin, school: school) }

      before do
        service.perform
      end

      it_behaves_like 'it correctly creates a contact', school_user: true
      it_behaves_like 'it adds interests correctly'

      context 'when user is not active' do
        let!(:user) { create(:school_admin, school: school, active: false) }

        it 'does not add any interests' do
          expect(contact.interests).to eq('')
        end
      end

      context 'when not adding defaults' do
        let(:add_default_interests) { false }

        # still add them here as user has not expressed a preference yet
        it_behaves_like 'it adds interests correctly'
      end
    end

    context 'with a group admin' do
      let!(:user) { create(:group_admin, school_group: create(:school_group, :with_default_scoreboard, default_issues_admin_user: nil)) }

      before do
        service.perform
      end

      it_behaves_like 'it correctly creates a contact', group_admin: true
      it_behaves_like 'it adds interests correctly'
    end

    context 'with an admin' do
      let!(:user) { create(:admin) }

      before do
        service.perform
      end

      it_behaves_like 'it correctly creates a contact'
      it_behaves_like 'it adds interests correctly'
    end

    context 'with an unconfirmed user' do
      let!(:user) { create(:school_admin, confirmed_at: nil) }

      before do
        service.perform
      end

      it 'ignores the user' do
        expect(service.new_nonsubscribed).to be_empty
      end
    end

    context 'with a pupil' do
      let!(:user) { create(:pupil) }

      before do
        service.perform
      end

      it 'ignores the user' do
        expect(service.new_nonsubscribed).to be_empty
      end
    end

    context 'with a school onboarding user' do
      let!(:user) { create(:onboarding_user)}

      before do
        service.perform
      end

      it 'ignores the user' do
        expect(service.new_nonsubscribed).to be_empty
      end
    end
  end

  context 'when there is a mixture of user types' do
    let!(:school_group) { create(:school_group, :with_default_scoreboard, default_issues_admin_user: nil) }
    let!(:school) { create(:school, :with_scoreboard, :with_local_authority, region: :east_midlands, percentage_free_school_meals: 35, school_group: school_group) }
    let!(:school_admin) { create(:school_admin, school: school) }
    let!(:group_admin) { create(:group_admin, school_group: school_group) }
    let!(:staff) { create(:staff) }
    let!(:other_staff) { create(:staff) }
    let!(:admin) { create(:admin) }

    let(:subscribed) do
      [
        create_contact('user@example.org', first_name: 'John', last_name: 'Smith', school_or_organisation: 'DfE', user_type: 'School management', other_la: 'bhcc', other_mat: 'Unity Schools Partnership', local_authority_and_mats: 'Other', tags: 'trustee,external support'),
        create_contact(school_admin.email)
      ]
    end

    let(:cleaned) do
      [create_contact(group_admin.email)]
    end

    let(:unsubscribed) do
      [create_contact(staff.email)]
    end

    let(:nonsubscribed) do
      [create_contact(other_staff.email)]
    end

    before do
      service.perform
    end

    it 'creates contacts for all user types' do
      expect(service.updated_audience[:subscribed].map(&:email_address)).to contain_exactly('user@example.org', school_admin.email)

      expect(service.updated_audience[:unsubscribed].map(&:email_address)).to contain_exactly(staff.email)

      expect(service.updated_audience[:cleaned].map(&:email_address)).to contain_exactly(group_admin.email)

      expect(service.updated_audience[:nonsubscribed].map(&:email_address)).to contain_exactly(other_staff.email)

      expect(service.new_nonsubscribed.first.email_address).to eq admin.email
    end
  end
end

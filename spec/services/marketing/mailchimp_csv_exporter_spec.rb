require 'rails_helper'

describe Marketing::MailchimpCsvExporter do
  subject(:service) do
    described_class.new(subscribed: subscribed, nonsubscribed: nonsubscribed, unsubscribed: unsubscribed, cleaned: cleaned)
  end

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

  shared_examples 'it correctly creates a contact' do |school_user: false, group_admin: false|
    it 'populates the common fields' do
      expect(contact.email_address).to eq user.email
      expect(contact.name).to eq user.name
      expect(contact.contact_source).to eq 'User'
      expect(contact.confirmed_date).to eq user.confirmed_at.to_date.iso8601
      expect(contact.user_role).to eq user.role.humanize
      expect(contact.locale).to eq user.preferred_locale
      expect(contact.interests).to eq 'Newsletter'
    end

    it 'populates school user fields', if: school_user do
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

    it 'populates group admin fields', if: group_admin do
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

  context 'when all the contacts are Users' do
    let(:subscribed) do
      [create_contact(user.email)]
    end

    let(:contact) do
      service.updated_audience[:subscribed].first
    end

    context 'with a school admin' do
      let!(:school) { create(:school, :with_school_group, :with_scoreboard, :with_local_authority, region: :east_midlands, percentage_free_school_meals: 35) }
      let!(:user) { create(:school_admin, school: school) }

      before do
        service.perform
      end

      it 'matches the contact' do
        expect(service.updated_audience[:subscribed].length).to eq(1)
      end

      it_behaves_like 'it correctly creates a contact', school_user: true

      it 'populates tags' do
        expect(contact.tags).to eq('FSM30')
      end

      context 'with existing interests' do
        let(:subscribed) do
          [create_contact(user.email, interests: 'Newsletter,Others')]
        end

        it 'preserves the interests' do
          expect(contact.interests).to eq('Newsletter,Others')
        end
      end

      context 'with existing non free school meal tags' do
        let(:subscribed) do
          [create_contact(user.email, tags: 'external support')]
        end

        it 'preserves the tags' do
          expect(contact.tags).to eq('external support,FSM30')
        end
      end

      context 'with existing free school meal tags' do
        let(:subscribed) do
          [create_contact(user.email, tags: 'FSM10')]
        end

        it 'overwrites the tags' do
          expect(contact.tags).to eq('FSM30')
        end
      end

      context 'with mixed case email' do
        let(:subscribed) do
          [create_contact(user.email.upcase)]
        end

        it_behaves_like 'it correctly creates a contact', school_user: true
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
      end
    end

    context 'with a group admin' do
      let!(:user) { create(:group_admin, school_group: create(:school_group, :with_default_scoreboard)) }

      before do
        service.perform
      end

      it_behaves_like 'it correctly creates a contact', group_admin: true
    end

    context 'with a cluster admin' do
      it 'populates the fields correctly'
    end

    context 'with an admin' do
      let!(:user) { create(:admin) }

      before do
        service.perform
      end

      it_behaves_like 'it correctly creates a contact'
    end
  end

  context 'when contacts are not Users' do
    context 'with a pre-migration contact' do
      let(:subscribed) do
        [create_contact('user@example.org', first_name: 'John', last_name: 'Smith', school_or_organisation: 'DfE', user_type: 'School management', other_la: 'bhcc', other_mat: 'Unity Schools Partnership', local_authority_and_mats: 'Other', tags: 'trustee,external support')]
      end

      let(:contact) do
        service.updated_audience[:subscribed].first
      end

      before do
        service.perform
      end

      it 'retains the contact' do
        expect(service.updated_audience[:subscribed].length).to eq(1)
      end

      it 'populates the fields correctly' do
        expect(contact.email_address).to eq('user@example.org')
        expect(contact.name).to eq 'John Smith'
        expect(contact.contact_source).to eq 'Organic'
        expect(contact.confirmed_date).to be_nil
        expect(contact.user_role).to be_nil
        expect(contact.locale).to eq 'en'
        expect(contact.interests).to eq 'Newsletter'
        expect(contact.tags).to eq 'trustee,external support'

        expect(contact.staff_role).to eq 'School management'
        expect(contact.school).to eq 'DfE'
        expect(contact.school_group).to eq 'Unity Schools Partnership'
      end
    end

    context 'with a post-migration contact' do
      let(:subscribed) do
        [create_contact('user@example.org', name: 'John Smith', first_name: 'John', last_name: 'XSmith', school: 'DfE', user_type: 'School management', school_group: 'Unity Schools Partnership', school_or_organisation: 'XDfE', user_type: 'School management', other_la: 'Xbhcc', other_mat: 'XUnity Schools Partnership', local_authority_and_mats: 'Other', tags: 'trustee,external support')]
      end

      let(:contact) do
        service.updated_audience[:subscribed].first
      end

      before do
        service.perform
      end

      it 'populates the fields correctly' do
        expect(contact.email_address).to eq('user@example.org')
        expect(contact.name).to eq 'John Smith'
        expect(contact.contact_source).to eq 'Organic'
        expect(contact.confirmed_date).to be_nil
        expect(contact.user_role).to be_nil
        expect(contact.locale).to eq 'en'
        expect(contact.interests).to eq 'Newsletter'
        expect(contact.tags).to eq 'trustee,external support'

        expect(contact.staff_role).to eq 'School management'
        expect(contact.school).to eq 'DfE'
        expect(contact.school_group).to eq 'Unity Schools Partnership'
      end
    end
  end

  context 'when there contacts that are Users and some that are not' do
    it 'creates contacts for both'

    context 'with a pupil' do
      let!(:user) { create(:pupil) }

      it 'ignores the user'
    end

    context 'with a school onboarding user' do
      it 'ignores the user'
    end
  end
end

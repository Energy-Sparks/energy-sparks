require 'rails_helper'

describe Mailchimp::CsvImporter do
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

  describe '#perform' do
    context 'when there are users in the export' do
      let!(:school_admin) { create(:school_admin) }
      let!(:group_admin) { create(:group_admin) }

      let(:subscribed) do
        [create_contact(school_admin.email)]
      end

      let(:unsubscribed) do
        [create_contact(group_admin.email)]
      end

      before do
        service.perform
      end

      it 'updates the status' do
        school_admin.reload
        expect(school_admin.mailchimp_status).to eq('subscribed')
        group_admin.reload
        expect(group_admin.mailchimp_status).to eq('unsubscribed')
      end
    end
  end
end

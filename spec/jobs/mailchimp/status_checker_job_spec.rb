require 'rails_helper'

describe Mailchimp::StatusCheckerJob do
  subject(:job) { described_class.new }

  let(:double) { instance_double(Mailchimp::AudienceManager) }

  before do
    allow(Mailchimp::AudienceManager).to receive(:new).and_return(double)
  end

  describe '#can_run?' do
    it 'can run in all environments' do
      ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'production' do
        expect(job.can_run?).to be(true)
      end
      ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'test' do
        expect(job.can_run?).to be(true)
      end
    end
  end

  describe '#perform' do
    let(:email_address) { 'test@example.org' }
    let!(:user) { create(:user, email: email_address) }
    let!(:school_admin) { create(:school_admin, mailchimp_status: :subscribed) }

    let(:member) do
      member = ActiveSupport::OrderedOptions.new
      member.email_address = email_address
      member.status = 'unsubscribed'
      member
    end

    before do
      allow(double).to receive(:process_list_members).and_return([member])
    end

    it 'updates statuses of all users' do
      expect(double).to receive(:process_list_members)
      job.perform
      user.reload
      expect(user.mailchimp_status).to eq('unsubscribed')
      school_admin.reload
      expect(school_admin.mailchimp_status).to be_nil
    end
  end
end

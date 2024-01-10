require 'rails_helper'

RSpec.describe Schools::BillRequestService do
  let!(:school)           { create(:school) }
  let!(:service)          { Schools::BillRequestService.new(school) }
  let(:email)             { ActionMailer::Base.deliveries.last }
  let(:email_body)        { email.html_part.decoded }

  context 'listing users' do
    context 'with no users' do
      it 'returns empty list' do
        expect(service.users).to eql([])
      end
    end

    context 'with users' do
      let!(:school_admin)     { create(:school_admin, school: school)}
      let!(:cluster_admin)    { create(:school_admin, name: "Cluster admin", cluster_schools: [school]) }
      let!(:staff)            { create(:staff, school: school)}
      let!(:pupil)            { create(:pupil, school: school)}

      it 'returns only staff and school admins' do
        expect(service.users).to match_array([staff, cluster_admin, school_admin])
      end
    end

    context 'with group admin cluster user (without staff role)' do
      let!(:school_admin)   { create(:school_admin, school: school)}
      let!(:group_admin)    { create(:group_admin, school: school)}

      before do
        school.cluster_users << group_admin
      end

      it 'returns users with empty staff roles last' do
        expect(service.users).to eq([school_admin, group_admin])
      end
    end

    context 'with group admin (not in cluster)' do
      let!(:school_group)   { create(:school_group, schools: [school])}
      let!(:school_admin)   { create(:school_admin, school: school)}
      let!(:group_admin)    { create(:group_admin, school_group: school_group)}

      it 'returns group admin users last' do
        expect(service.users).to eq([school_admin, group_admin])
      end
    end
  end

  describe '#request_documentation!' do
    let!(:school_admin) { create(:school_admin, school: school)}

    it 'generates an email' do
      expect do
        service.request_documentation!([school_admin])
      end.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
    end

    it 'sets flag on school' do
      expect do
        service.request_documentation!([school_admin])
      end.to change(school, :bill_requested).from(false).to(true).and change { school.bill_requested_at.class }.from(NilClass).to(ActiveSupport::TimeWithZone)
    end

    context 'when formatting email' do
      before do
        service.request_documentation!([school_admin])
      end

      it 'sends to the correct users' do
        expect(email.to).to match_array([school_admin.email])
      end

      it 'has the expected subject line' do
        expect(email.subject).to eql("Please upload a recent energy bill to Energy Sparks")
      end

      it 'includes the school name' do
        expect(email_body).to include(school.name)
      end

      it 'includes a link to the upload a bill page' do
        node = Capybara::Node::Simple.new(email_body)
        expect(node).to have_link('Upload your bill')
      end
    end

    context 'when user has a locale' do
      before do
        school_admin.update(preferred_locale: :cy)
        service.request_documentation!([school_admin])
      end

      it 'has the expected subject line' do
        expect(email.subject).to eql("Uwchlwythwch fil ynni diweddar i Sbarcynni")
      end
    end

    context 'with mpans' do
      let!(:electricity_meter)  { create(:electricity_meter, school: school)}
      let!(:gas_meter)          { create(:gas_meter, school: school)}

      it 'includes the requested MPANs' do
        service.request_documentation!([school_admin], [electricity_meter, gas_meter])
        expect(email_body).to include(electricity_meter.mpan_mprn.to_s)
        expect(email_body).to include(gas_meter.mpan_mprn.to_s)
      end
    end
  end
end

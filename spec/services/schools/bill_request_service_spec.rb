require 'rails_helper'

RSpec.describe Schools::BillRequestService do

  let!(:school)           { create(:school) }
  let!(:service)          { Schools::BillRequestService.new(school) }

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

      it 'should return only staff and school admins' do
        expect(service.users).to match_array([staff, cluster_admin, school_admin])
      end

    end

  end

  context '#request_documentation!' do
    let!(:school_admin)     { create(:school_admin, school: school)}

    it 'should generate an email' do
      expect{
        service.request_documentation!([school_admin])
      }.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
    end

    it 'should set flag on school' do
      expect{
        service.request_documentation!([school_admin])
      }.to change(school, :bill_requested).from(false).to(true)
    end

    context 'when formatting email' do
        before(:each) do
          service.request_documentation!([school_admin])
          @email = ActionMailer::Base.deliveries.last
        end

        it 'should send to the correct users' do
          expect(@email.to).to match_array([school_admin.email])
        end

        it 'should have the expected subject line' do
          expect(@email.subject).to eql("Please upload a recent energy bill to Energy Sparks")
        end

        it 'should include the school name' do
          email_body = @email.html_part.body.to_s
          expect(email_body).to include(school.name)
        end

        it 'should include a link to the upload a bill page' do
          email_body = @email.html_part.body.to_s
          node = Capybara::Node::Simple.new(email_body)
          expect(node).to have_link('Upload your bill')
        end

    end

    context 'with mpans' do
      let!(:electricity_meter)  { create(:electricity_meter, school: school)}
      let!(:gas_meter)          { create(:gas_meter, school: school)}

      it 'should include the requested MPANs' do
        service.request_documentation!([school_admin], [electricity_meter, gas_meter])
        @email = ActionMailer::Base.deliveries.last
        email_body = @email.html_part.body.to_s
        expect(email_body).to include(electricity_meter.mpan_mprn.to_s)
        expect(email_body).to include(gas_meter.mpan_mprn.to_s)
      end
    end

  end
end

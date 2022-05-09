require 'rails_helper'

RSpec.describe Schools::ConsentRequestService do

  let!(:school)           { create(:school) }
  let!(:service)          { Schools::ConsentRequestService.new(school) }

  context 'listing users' do

    context 'with no users' do
      it 'returns empty list' do
        expect(service.users).to eql([])
      end
    end

    context 'with users' do
      let!(:school_admin)     { create(:school_admin, school: school)}
      let!(:staff)            { create(:staff, school: school)}
      let!(:pupil)            { create(:pupil, school: school)}

      it 'should return only staff and school admins' do
        expect(service.users).to match_array([staff, school_admin])
      end
    end

  end

  context '#request_consent!' do
    let!(:school_admin)     { create(:school_admin, school: school)}

    it 'should generate an email' do
      expect{
        service.request_consent!([school_admin])
      }.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
    end

    context 'when formatting email' do
        before(:each) do
          service.request_consent!([school_admin])
          @email = ActionMailer::Base.deliveries.last
        end

        it 'should send to the correct users' do
          expect(@email.to).to match_array([school_admin.email])
        end

        it 'should have the expected subject line' do
          expect(@email.subject).to eql("We need permission to access your school's energy data")
        end

        it 'should include the school name' do
          email_body = @email.body.to_s
          expect(email_body).to include(school.name)
        end

        it 'should include a link to the give consent page' do
          email_body = @email.body.to_s
          node = Capybara::Node::Simple.new(email_body.to_s)
          expect(node).to have_link('Give consent')
        end

    end

  end
end

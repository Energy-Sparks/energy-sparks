require 'rails_helper'

RSpec.describe Schools::ConsentRequestService do
  let!(:preferred_locale) { :en }
  let!(:school)           { create(:school) }
  let!(:service)          { Schools::ConsentRequestService.new(school) }

  context 'listing users' do
    context 'with no users' do
      it 'returns empty list' do
        expect(service.users).to eql([])
      end
    end

    context 'with users' do
      let!(:school_admin) { create(:school_admin, school: school) }
      let!(:staff)        { create(:staff, school: school) }
      let!(:pupil)        { create(:pupil, school: school) }

      it 'returns only staff and school admins' do
        expect(service.users).to match_array([staff, school_admin])
      end
    end
  end

  describe '#request_consent!' do
    let!(:school_admin) { create(:school_admin, school: school, preferred_locale: preferred_locale) }

    it 'generates an email' do
      expect do
        service.request_consent!([school_admin])
      end.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
    end

    context 'when formatting email' do
      before do
        service.request_consent!([school_admin])
        @email = ActionMailer::Base.deliveries.last
      end

      it 'sends to the correct users' do
        expect(@email.to).to match_array([school_admin.email])
      end

      it 'has the expected subject line' do
        expect(@email.subject).to eql("We need permission to access your school's energy data")
      end

      it 'includes the school name' do
        email_body = @email.html_part.decoded
        expect(email_body).to include(school.name)
      end

      it 'includes a link to the give consent page' do
        email_body = @email.html_part.decoded
        node = Capybara::Node::Simple.new(email_body.to_s)
        expect(node).to have_link('Give consent')
      end

      context 'when preferred locale is cy' do
        let!(:preferred_locale) { :cy }

        it 'has the expected subject line' do
          expect(@email.subject).to eql('Mae angen caniatâd arnom i gael mynediad at ddata ynni eich ysgol')
        end
      end
    end

    context 'when formatting multiple emails' do
      let!(:preferred_locale) { :cy }
      let!(:staff)            { create(:staff, school: school) }

      it 'generates 2 emails' do
        expect do
          service.request_consent!([school_admin, staff])
        end.to change(ActionMailer::Base.deliveries, :count).from(0).to(2)
      end

      context 'when locales are different' do
        before do
          service.request_consent!([school_admin, staff])
        end

        it 'email should have en and cy subject line' do
          emails = ActionMailer::Base.deliveries.last(2)
          expected_subjects = [
            'Mae angen caniatâd arnom i gael mynediad at ddata ynni eich ysgol',
            "We need permission to access your school's energy data"
          ]
          expect(emails.map(&:subject)).to match_array(expected_subjects)
        end
      end
    end
  end
end

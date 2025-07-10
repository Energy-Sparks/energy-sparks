require 'rails_helper'

RSpec.describe DccMailer do
  let(:school_1)    { create(:school, :with_school_group, name: 'Big School') }
  let(:school_2)    { create(:school, :with_school_group, name: 'Little School') }
  let(:meter_1)     { create(:electricity_meter, dcc_meter: :smets2, school: school_1) }
  let(:meter_2)     { create(:electricity_meter, dcc_meter: :no, school: school_2) }
  let(:meter_ids)   { [meter_1.id, meter_2.id] }

  describe '#dcc_meter_status_email' do
    it 'sends an email with meter ids' do
      DccMailer.with(meter_ids: meter_ids).dcc_meter_status_email.deliver_now
      expect(ActionMailer::Base.deliveries.count).to be 1
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eql 'New smart meters found'
      expect(email.html_part.decoded).to include(school_1.school_group.name)
      expect(email.html_part.decoded).to include(school_1.school_group.default_issues_admin_user.name)
      expect(email.html_part.decoded).to include(meter_1.school.name)
      expect(email.html_part.decoded).to include(meter_1.mpan_mprn.to_s)

      expect(email.html_part.decoded).to include(school_2.school_group.name)
      expect(email.html_part.decoded).to include(school_2.school_group.default_issues_admin_user.name)
      expect(email.html_part.decoded).to include(meter_1.school.name)
      expect(email.html_part.decoded).to include(meter_2.mpan_mprn.to_s)

      expect(email.html_part.decoded).to include('SMETS2')
    end
  end
end

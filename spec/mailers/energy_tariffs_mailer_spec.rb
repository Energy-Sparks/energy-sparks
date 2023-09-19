require 'rails_helper'

RSpec.describe EnergyTariffsMailer, include_application_helper: true do
  describe '#group_admin_review_group_tariffs_reminder' do
    let!(:school_group) { create(:school_group) }
    let!(:school_group_admin) { create(:group_admin, school_group: school_group) }

    it 'sends group admins a review group tariffs reminder email' do
      EnergyTariffsMailer.with(school_group_id: school_group.id).group_admin_review_group_tariffs_reminder.deliver_now
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("Provide your school’s energy tariffs to Energy Sparks")
      expect(email.to).to eq([school_group_admin.email])
      expect(email.body.to_s).to include("To help Energy Sparks to provide you with accurate estimates of your energy costs and potential savings, we&#8217;re contacting you to ask you to review the information we have about your schools' energy tariffs.")
      expect(email.body.to_s).to include('<a href="http://localhost/school_groups/' + school_group.slug + '/energy_tariffs" style="color: #0d6efd;">Click here</a> to review your current tariffs and to add or update the information based on your latest contract. You can choose to provide an average tariff for your group contract or individual tariffs for each school.')
      expect(email.body.to_s).to include("In future, please remember to update your schools' tariffs on Energy Sparks when you change supply contract.")
    end
  end

  describe '#school_admin_review_school_tariffs_reminder' do
    let(:school) { create(:school) }
    let!(:school_admin) { create(:school_admin, school: school) }
    let!(:staff) { create(:staff, school: school) }
    let!(:pupil) { create(:pupil, school: school) }

    it 'sends school admins a review school tariffs reminder email' do
      EnergyTariffsMailer.with(school_id: school.id).school_admin_review_school_tariffs_reminder.deliver_now
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("Provide your schools' energy tariffs to Energy Sparks")
      expect(email.to).to eq([school_admin.email])
      expect(email.body.to_s).to include("To help Energy Sparks to provide you with accurate estimates of your energy costs and potential savings, we&#8217;re contacting you to ask you to review the information we have about your school&#8217;s energy tariffs.")
      expect(email.body.to_s).to include('<a href="http://localhost/schools/' + school.slug + '/energy_tariffs" style="color: #0d6efd;">Click here</a> to review your current tariffs and to add or update the information based on your latest contract.')
      expect(email.body.to_s).to include("In future, please remember to update your tariffs on Energy Sparks when you change supply contract.")
    end
  end
end

require 'rails_helper'

RSpec.describe EnergyTariffsMailer, include_application_helper: true do
  around do |example|
    ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
      example.run
    end
  end

  describe '#group_admin_review_group_tariffs_reminder' do
    let!(:school_group) { create(:school_group, group_type: :multi_academy_trust) }
    let!(:school_group_admin) { create(:group_admin, school_group: school_group) }

    context "preferred locale is cy" do
      it 'sends group admins a review group tariffs reminder email' do
        school_group_admin.update(preferred_locale: :cy)

        EnergyTariffsMailer.with(school_group_id: school_group.id).group_admin_review_group_tariffs_reminder.deliver_now
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.subject', school_group_name: school_group.name, locale: :cy))
        expect(email.to).to eq([school_group_admin.email])
        #encountered some character encoding issues â and ŵ being escape to &#xxxx; and unclear how to force that encoding when checking against YAML
        #So instead check for text explicitly
        expect(email.body.to_s).to include('Ymddiriedolaeth Aml-Academi')
        expect(email.body.to_s).to include("http://cy.localhost/school_groups/#{school_group.slug}/energy_tariffs")
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.you_can_set', locale: :cy))
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.to_review', locale: :cy))
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.in_future', locale: :cy))
      end
    end

    context "preferred locale is en" do
      it 'sends group admins a review group tariffs reminder email' do
        school_group_admin.update(preferred_locale: :en)

        EnergyTariffsMailer.with(school_group_id: school_group.id).group_admin_review_group_tariffs_reminder.deliver_now
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.subject', school_group_name: school_group.name, locale: :en))
        expect(email.to).to eq([school_group_admin.email])
        expect(email.body.to_s).to include('Multi-Academy Trust')
        expect(email.body.to_s).to include("http://localhost/school_groups/#{school_group.slug}/energy_tariffs")
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.you_can_set', locale: :en))
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.to_review', locale: :en))
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.in_future', locale: :en))
      end
    end
  end

  describe '#school_admin_review_school_tariffs_reminder' do
    let(:school) { create(:school) }
    let!(:school_admin) { create(:school_admin, school: school) }
    let!(:staff) { create(:staff, school: school) }
    let!(:pupil) { create(:pupil, school: school) }

    context "preferred locale is en" do
      it 'sends school admins a review school tariffs reminder email' do
        school_admin.update(preferred_locale: :en)

        EnergyTariffsMailer.with(school_id: school.id).school_admin_review_school_tariffs_reminder.deliver_now
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.subject', school_name: school.name, locale: :en))
        expect(email.to).to eq([school_admin.email])
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.mail_body.to_help', school_name: school.name, locale: :en))
        expect(email.body.to_s).to include("http://localhost/schools/#{school.slug}/energy_tariffs")
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.mail_body.to_review', locale: :en))
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.mail_body.in_future', locale: :en))
      end
    end

    context "preferred locale is cy" do
      it 'sends school admins a review school tariffs reminder email' do
        school_admin.update(preferred_locale: :cy)

        EnergyTariffsMailer.with(school_id: school.id).school_admin_review_school_tariffs_reminder.deliver_now
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.subject', school_name: school.name, locale: :cy))
        expect(email.to).to eq([school_admin.email])
        expect(email.body.to_s).to include("tariffau ynni ar gyfer #{school.name}")
        expect(email.body.to_s).to include("http://cy.localhost/schools/#{school.slug}/energy_tariffs")
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.mail_body.to_review', locale: :cy))
        expect(email.body.to_s).to include(I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.mail_body.in_future', locale: :cy))
      end
    end
  end
end

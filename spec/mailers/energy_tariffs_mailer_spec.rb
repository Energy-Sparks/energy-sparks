# frozen_string_literal: true

require 'rails_helper'

describe EnergyTariffsMailer, :include_application_helper do
  include EmailHelpers

  # before { stub_const('ENV', ENV.to_h.merge('WELSH_APPLICATION_HOST' => 'cy.localhost')) }
  before { stub_env(SEND_AUTOMATED_EMAILS: true) }

  # around do |example|
  #   ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
  #     example.run
  #   end
  # end
  def read_md(name)
    File.read(File.join(__dir__, 'onboarding_mailer2025', "#{name}.md"))
        .gsub('[CALENDAR_ID]', school.calendar_id.to_s)
  end

  let(:school) { create(:school, :with_school_group) }

  def expected_subject(name)
    "It's time to review the energy tariffs for #{name} on Energy Sparks"
  end

  def deliver(user, accessor, tariff)
    described_class.reminder_deliver_later_per_locale(user.public_send(accessor), [user], tariff)
    perform_enqueued_jobs
  end

  context 'with tariff set' do
    before do
      create(:energy_tariff, tariff_holder:)
      SiteSettings.current.update!(prices: { electricity_price: 0.15, gas_price: 0.03 })
      described_class.reminder(user, true).deliver_now
    end

    def expected_body(organisation)
      if organisation.is_a?(School)
        type = :school
        url = school_energy_tariffs_url(organisation)
        account = 'your account'
      else
        type = :group
        url = school_group_energy_tariffs_url(organisation)
        account = 'the school accounts'
      end
      <<~MD.chomp

        Thank you for updating your #{type}'s tariff information. The current tariffs will expire in 30 days' time. Don't forget to update your tariff information for the next supply contract period.

        To do this, please login to Energy Sparks, click on the **Manage School** menu and select [**Manage tariffs**](#{url})

        If the tariff information isn't updated, we will apply the Energy Sparks default tariff to #{account} of 15p per kWh of electricity and 3p per kWh of gas.

        If you are planning to switch suppliers when your current contract ends, please inform us by emailing your [Energy Sparks account manager](mailto:#{organisation.default_issues_admin_user.email}) as we will need to contact your new supplier(s) to maintain data access.
      MD
    end

    context 'with a school admin' do
      let(:user) { create(:school_admin, school:) }
      let(:tariff_holder) { school }

      it 'sends the expected email' do
        expect(last_email.subject).to eq(expected_subject(school.name))
        expect(bootstrap_email_body_to_markdown(last_email)).to eq(expected_body(school))
      end
    end

    context 'with a group admin' do
      let(:user) { create(:group_admin, school_group: school.school_group) }
      let(:tariff_holder) { user.school_group }

      it 'sends the expected email' do
        expect(last_email.subject).to eq(expected_subject(school.school_group.name))
        expect(bootstrap_email_body_to_markdown(last_email)).to eq(expected_body(school.school_group))
      end
    end
  end

  context 'with no tariff set' do
    let!(:tariff) { nil }

    def expected_body(organisation)
      url = if organisation.is_a?(School)
              school_energy_tariffs_url(organisation)
            else
              school_group_energy_tariffs_url(organisation)
            end

      ["\nTo help Energy Sparks to provide you with accurate estimates of your energy costs and potential savings, " \
       "we're contacting you to ask you to review the information we have about the energy tariffs for " \
       "#{organisation.name}.",
       (unless organisation.is_a?(School)
          'You can set an average tariff for all schools to provide better defaults for all schools. Individual ' \
            'schools can add their own tariff information.'
        end),
       'To review your current tariffs and to add or update the information based on your latest contract, please ' \
       "visit your [Manage tariffs](#{url}) page. For more details about how to set up tariffs, please see the " \
       '[Tariff Editor User guide](https://energysparks.uk/resources/28/inline).',
       "It's best to update your tariffs on Energy Sparks when you change supply contract. Don't forget, if your " \
       "#{organisation.model_name.human.downcase} is planning to switch suppliers when you change supply contract, " \
       'please inform us by your [Energy Sparks account manager]' \
       "(mailto:#{organisation.default_issues_admin_user.email}) as we will need to " \
       'contact your new supplier(s) to maintain data access.'].compact.join("\n\n")
    end

    context 'with a school admin' do
      let(:user) { create(:school_admin, school:) }

      before { deliver(user, :school, tariff) }

      it 'sends the expected email' do
        expect(last_email.subject).to eq(expected_subject(school.name))
        expect(bootstrap_email_body_to_markdown(last_email)).to eq(expected_body(school))
      end

      # fcontext 'with an expired tariff' do
      #   let(:tariff) { create(:energy_tariff, tariff_holder: user.school, end_date: 1.day.ago) }

      #   it 'sends the expected email' do
      #     expect(last_email.subject).to eq(expected_subject(school.name))
      #     expect(bootstrap_email_body_to_markdown(last_email)).to eq(expected_body(school))
      #   end
      # end
    end

    context 'with a group admin' do
      let(:user) { create(:group_admin, school_group: school.school_group) }

      before { deliver(user, :school_group, nil) }

      it 'sends the expected email' do
        expect(last_email.subject).to eq(expected_subject(school.school_group.name))
        expect(bootstrap_email_body_to_markdown(last_email)).to eq(expected_body(school.school_group))
      end
    end
  end

  context 'when tariff has expired' do
  end

  context 'with a tariff set a year ago with no end date' do
  end
  # end

  describe '#group_admin_review_group_tariffs_reminder' do
    let!(:school_group) { create(:school_group, group_type: :multi_academy_trust) }
    let!(:school_group_admin) { create(:group_admin, school_group: school_group) }

    context 'preferred locale is cy' do
      it 'sends group admins a review group tariffs reminder email' do
        school_group_admin.update(preferred_locale: :cy)

        described_class.with(school_group_id: school_group.id).group_admin_review_group_tariffs_reminder.deliver_now
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.subject',
                                           school_group_name: school_group.name, locale: :cy))
        expect(email.to).to eq([school_group_admin.email])
        # encountered some character encoding issues â and ŵ being escape to &#xxxx; and unclear how to force that encoding when checking against YAML
        # So instead check for text explicitly
        expect(email.html_part.decoded).to include('Ymddiriedolaeth Aml-Academi')
        expect(email.html_part.decoded).to include("http://cy.localhost/school_groups/#{school_group.slug}/energy_tariffs")
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.you_can_set', locale: :cy
                                                   ))
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.to_review', locale: :cy
                                                   ))
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.in_future', locale: :cy
                                                   ))
      end
    end

    context 'preferred locale is en' do
      it 'sends group admins a review group tariffs reminder email' do
        school_group_admin.update(preferred_locale: :en)

        described_class.with(school_group_id: school_group.id).group_admin_review_group_tariffs_reminder.deliver_now
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.subject',
                                           school_group_name: school_group.name, locale: :en))
        expect(email.to).to eq([school_group_admin.email])
        expect(email.html_part.decoded).to include('Multi-Academy Trust')
        expect(email.html_part.decoded).to include("http://localhost/school_groups/#{school_group.slug}/energy_tariffs")
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.you_can_set', locale: :en
                                                   ))
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.to_review', locale: :en
                                                   ))
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.mail_body.in_future', locale: :en
                                                   ))
      end
    end
  end

  describe '#school_admin_review_school_tariffs_reminder' do
    let(:school) { create(:school) }
    let!(:school_admin) { create(:school_admin, school: school) }
    let!(:staff) { create(:staff, school: school) }
    let!(:pupil) { create(:pupil, school: school) }

    context 'preferred locale is en' do
      it 'sends school admins a review school tariffs reminder email' do
        school_admin.update(preferred_locale: :en)

        described_class.with(school_id: school.id).school_admin_review_school_tariffs_reminder.deliver_now
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.subject',
                                           school_name: school.name, locale: :en))
        expect(email.to).to eq([school_admin.email])
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.mail_body.to_help', school_name: school.name, locale: :en
                                                   ))
        expect(email.html_part.decoded).to include("http://localhost/schools/#{school.slug}/energy_tariffs")
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.mail_body.to_review', locale: :en
                                                   ))
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.mail_body.in_future', locale: :en
                                                   ))
      end
    end

    context 'preferred locale is cy' do
      it 'sends school admins a review school tariffs reminder email' do
        school_admin.update(preferred_locale: :cy)

        described_class.with(school_id: school.id).school_admin_review_school_tariffs_reminder.deliver_now
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.subject',
                                           school_name: school.name, locale: :cy))
        expect(email.to).to eq([school_admin.email])
        expect(email.html_part.decoded).to include("tariffau ynni ar gyfer #{school.name}")
        expect(email.html_part.decoded).to include("http://cy.localhost/schools/#{school.slug}/energy_tariffs")
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.mail_body.to_review', locale: :cy
                                                   ))
        expect(email.html_part.decoded).to include(I18n.t(
                                                     'energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.mail_body.in_future', locale: :cy
                                                   ))
      end
    end
  end
end

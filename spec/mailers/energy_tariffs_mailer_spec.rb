# frozen_string_literal: true

require 'rails_helper'

describe EnergyTariffsMailer, :include_application_helper do
  include EmailHelpers

  let(:school) { create(:school, :with_school_group) }
  let(:tariff) { nil }

  before do
    stub_env(SEND_AUTOMATED_EMAILS: true)
    SiteSettings.current.update!(prices: { electricity_price: 0.15, gas_price: 0.03 })
    described_class.reminder_deliver_now_per_locale(organisation, [user], expiring_tariffs: [tariff].compact)
  end

  def organisation = user.public_send({ school_admin: :school, group_admin: :school_group }[user.role.to_sym])

  def url(organisation)
    if organisation.is_a?(School)
      school_energy_tariffs_url(organisation)
    else
      school_group_energy_tariffs_url(organisation)
    end
  end

  shared_examples 'it sends the expected email' do
    it 'has the correct subject' do
      expect(last_email.subject).to \
        eq("It's time to review the energy tariffs for #{organisation.name} on Energy Sparks")
    end

    it 'sends the expected email' do
      expect(bootstrap_email_body_to_markdown(last_email)).to eq(expected_body.join("\n\n"))
    end
  end

  def currently_default_text
    'Currently our default tariff is set at 15p per kWh of electricity and 3p per kWh of gas.'
  end

  context 'with expiry set' do
    let(:tariff) { create(:energy_tariff, tariff_holder:) }
    let(:expected_body) do
      type = organisation.is_a?(School) ? :school : :group
      ["\nThank you for updating your #{type}'s electricity tariff information. The current tariffs will expire in " \
       "30 days' time. Don't forget to update your tariff information for the next supply contract period.",
       "To do this, please login to Energy Sparks, click on the **Manage #{type.capitalize}** menu and select " \
       "[**Manage tariffs**](#{url(organisation)})",
       "If the tariff isn't updated, we will apply the Energy Sparks default tariff to your account. This will be " \
       'used to calculate the potential cost savings for your energy saving activities.',
       currently_default_text,
       'If you are planning to switch suppliers when your current contract ends, please inform us by emailing your ' \
       "[Energy Sparks account manager](mailto:#{organisation.default_issues_admin_user.email}) as we will need to " \
       'contact your new supplier(s) to maintain data access.']
    end

    context 'with a school admin' do
      let(:user) { create(:school_admin, school:) }
      let(:tariff_holder) { school }

      it_behaves_like 'it sends the expected email'
    end

    context 'with a group admin' do
      let(:user) { create(:group_admin, school_group: school.school_group) }
      let(:tariff_holder) { user.school_group }

      it_behaves_like 'it sends the expected email'
    end
  end

  context 'with expiry not set' do
    let(:tariff) { nil }

    def to_help_text(name)
      "\nTo help Energy Sparks to provide you with accurate estimates of your energy costs and potential savings, " \
        "we're contacting you to ask you to review the information we have about the energy tariffs for " \
        "#{name}."
    end

    def to_review_text
      'To review your current tariffs and to add or update the information based on your latest contract, please ' \
        "visit your [Manage tariffs](#{url(organisation)}) page. For more details about how to set up tariffs, " \
        'please see the [Tariff Editor User guide](https://energysparks.uk/resources/28/inline).'
    end

    def its_best_text
      "It's best to update your tariffs on Energy Sparks when your supply contract changes."
    end

    def dont_forget_text(type)
      "Don't forget, if your #{type} is planning to switch suppliers when you change supply contract, please inform " \
        "us by emailing your [Energy Sparks account manager](mailto:#{organisation.default_issues_admin_user.email}) " \
        'as we will need to contact your new supplier(s) to maintain data access.'
    end

    context 'with a school admin' do
      let(:user) { create(:school_admin, school:) }
      let(:expected_body) do
        [to_help_text(organisation.name),
         to_review_text,
         its_best_text,
         *current_tariff_text,
         dont_forget_text('school')]
      end
      let(:current_tariff_text) do
        ['If we do not have current school or group tariffs we will apply the Energy Sparks default tariff to your ' \
         "account. #{this_will_be_text}",
         currently_default_text]
      end

      def this_will_be_text
        'This will be used to calculate the potential cost savings for your energy saving activities.'
      end

      it_behaves_like 'it sends the expected email'

      context 'with a group tariff' do
        let(:tariff) do
          create(:energy_tariff, :with_flat_price, tariff_holder: school.school_group, end_date: nil)
          nil
        end
        let(:current_tariff_text) do
          ['If we do not have current tariffs for your school we will apply your group tariff. If we do not have ' \
           'current school or group tariffs we will apply the Energy Sparks default tariff to your account. ' \
           "#{this_will_be_text}",
           'Currently your group tariff is set at 10p per kWh of electricity and our default tariff is set at 3p per ' \
           'kWh of gas.']
        end

        it_behaves_like 'it sends the expected email'
      end

      context 'with both group tariffs' do
        let(:tariff) do
          create(:energy_tariff, :with_flat_price, tariff_holder: school.school_group, end_date: nil)
          create(:energy_tariff, :with_flat_price, tariff_holder: school.school_group, end_date: nil, meter_type: :gas)
          nil
        end
        let(:current_tariff_text) do
          ["If we do not have current tariffs for your school we will apply your group tariff. #{this_will_be_text}",
           'Currently your group tariff is set at 10p per kWh of electricity and 10p per kWh of gas.']
        end

        it_behaves_like 'it sends the expected email'
      end
    end

    context 'with a group admin' do
      let(:user) { create(:group_admin, school_group: school.school_group) }
      let(:expected_body) do
        [to_help_text('your group'),
         'You can set an average tariff for all schools to provide better defaults for all schools. Individual ' \
         'schools can add their own tariff information.',
         'If your group tariffs aren’t updated, and the individual schools have not added their own tariffs, then we ' \
         'will apply the Energy Sparks default tariffs.',
         currently_default_text,
         to_review_text,
         [its_best_text, dont_forget_text('school group')].join(' ')]
      end

      it_behaves_like 'it sends the expected email'
    end
  end
end

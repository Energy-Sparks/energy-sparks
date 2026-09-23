# frozen_string_literal: true

require 'rails_helper'

describe EnergyTariffsMailer, :include_application_helper do
  include EmailHelpers

  let(:school) { create(:school, :with_school_group) }
  let(:tariff) { nil }

  before do
    stub_env(SEND_AUTOMATED_EMAILS: true)
    SiteSettings.current.update!(prices: { electricity_price: 0.15, gas_price: 0.03 })
    described_class.reminder_deliver_later_per_locale(organisation(user), [user], tariff)
    perform_enqueued_jobs
  end

  def expected_subject(name) = "It's time to review the energy tariffs for #{name} on Energy Sparks"

  def organisation(user)
    user.public_send({ school_admin: :school, group_admin: :school_group }[user.role.to_sym])
  end

  def url(organisation)
    if organisation.is_a?(School)
      school_energy_tariffs_url(organisation)
    else
      school_group_energy_tariffs_url(organisation)
    end
  end

  shared_examples 'it sends the expected email' do
    it 'has the correct subject' do
      expect(last_email.subject).to eq(expected_subject(organisation(user).name))
    end

    it 'sends the expected email' do
      expect(bootstrap_email_body_to_markdown(last_email)).to eq(expected_body(organisation(user)))
    end
  end

  context 'with tariff set' do
    let(:tariff) { create(:energy_tariff, tariff_holder:) }

    def expected_body(organisation)
      type, account = organisation.is_a?(School) ? [:school, 'your account'] : [:group, 'the school accounts']

      <<~MD.chomp

        Thank you for updating your #{type}'s tariff information. The current tariffs will expire in 30 days' time. Don't forget to update your tariff information for the next supply contract period.

        To do this, please login to Energy Sparks, click on the **Manage School** menu and select [**Manage tariffs**](#{url(organisation)})

        If the tariff information isn't updated, we will apply the Energy Sparks default tariff to #{account} of 15p per kWh of electricity and 3p per kWh of gas.

        If you are planning to switch suppliers when your current contract ends, please inform us by emailing your [Energy Sparks account manager](mailto:#{organisation.default_issues_admin_user.email}) as we will need to contact your new supplier(s) to maintain data access.
      MD
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

  context 'with no tariff set' do
    let(:tariff) { nil }

    def expected_body(organisation)
      type = organisation.is_a?(School) ? :school : :group

      ["\nTo help Energy Sparks to provide you with accurate estimates of your energy costs and potential savings, " \
       "we're contacting you to ask you to review the information we have about the energy tariffs for " \
       "#{organisation.name}.",
       (unless organisation.is_a?(School)
          'You can set an average tariff for all schools to provide better defaults for all schools. Individual ' \
            'schools can add their own tariff information.'
        end),
       'To review your current tariffs and to add or update the information based on your latest contract, please ' \
       "visit your [Manage tariffs](#{url(organisation)}) page. For more details about how to set up tariffs, please see the " \
       '[Tariff Editor User guide](https://energysparks.uk/resources/28/inline).',
       "It's best to update your tariffs on Energy Sparks when you change supply contract. Don't forget, if your " \
       "#{type} is planning to switch suppliers when you change supply contract, please inform us by your " \
       "[Energy Sparks account manager](mailto:#{organisation.default_issues_admin_user.email}) as we will need to " \
       'contact your new supplier(s) to maintain data access.'].compact.join("\n\n")
    end

    context 'with a school admin' do
      let(:user) { create(:school_admin, school:) }

      it_behaves_like 'it sends the expected email'
    end

    context 'with a group admin' do
      let(:user) { create(:group_admin, school_group: school.school_group) }

      it_behaves_like 'it sends the expected email'
    end
  end
end

#  frozen_string_literal: true

module Commercial
  class ExceptionReportPromptComponent < ApplicationComponent
    def render?
      onboardings_with_no_contracts.positive? ||
        unlicensed_schools.positive? ||
        overlapping_licences.positive? ||
        pending_invoices.positive?
    end

    def prompts
      [
        { id: 'unlicensed-schools', check: unlicensed_schools?, status: :negative,
          icon: 'school-circle-xmark', link: 'Unlicensed Schools', path: unlicensed_admin_commercial_licences_path,
          content: "There are currently #{unlicensed_schools} schools without licences." },
        { id: 'onboarding-no-contracts', check: onboardings_with_no_contracts?, status: :negative,
          icon: 'file-contract', link: 'Onboardings', path: admin_school_onboardings_path,
          content: "There are currently #{onboardings_with_no_contracts} incomplete onboardings
            without a contract specified." },
        { id: 'overlapping-licences', check: overlapping_licences?, status: :negative,
          icon: 'calendar-xmark', link: 'Overlapping Licences', path: overlapping_admin_commercial_licences_path,
          content: "There are currently #{overlapping_licences} overlapping licences for the same school." },
        { id: 'pending-invoices', check: pending_invoices?, status: :negative,
          icon: 'file-invoice', link: 'Pending invoices', path: pending_invoicing_admin_commercial_contracts_path,
          content: "There are #{pending_invoices} current contracts with pending invoices." }
      ]
    end

    private

    def unlicensed_schools?
      unlicensed_schools.positive?
    end

    def unlicensed_schools
      @unlicensed_schools ||= School.active.without_current_licence.count
    end

    def onboardings_with_no_contracts?
      onboardings_with_no_contracts.positive?
    end

    def onboardings_with_no_contracts
      @onboardings_with_no_contracts ||= SchoolOnboarding.incomplete.where(contract: nil).count
    end

    def overlapping_licences?
      overlapping_licences.positive?
    end

    def overlapping_licences
      @overlapping_licences ||= Commercial::Licence.overlapping.count
    end

    def pending_invoices?
      pending_invoices.positive?
    end

    def pending_invoices
      @pending_invoices ||= ::Commercial::Contract.pending_invoicing.current.count
    end

    def add_prompt(list:, status:, icon:, check: true, id: nil, link: nil, path: nil) # rubocop:disable Metrics/ParameterLists
      return unless check

      list.with_prompt id: id, status: status, icon: icon do |p|
        yield
        p.with_link { helpers.link_to link, path } if link
      end
    end
  end
end

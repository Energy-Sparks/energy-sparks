#  frozen_string_literal: true

module Commercial
  class ExceptionReportPromptComponent < ApplicationComponent
    def render?
      onboardings_with_no_contracts.positive? || unlicensed_schools.positive? || overlapping_licences.positive?
    end

    private

    def unlicensed_schools
      @unlicensed_schools ||= School.active.without_current_licence.count
    end

    def onboardings_with_no_contracts
      @onboardings_with_no_contracts ||= SchoolOnboarding.incomplete.where(contract: nil).count
    end

    def overlapping_licences
      @overlapping_licences ||= Commercial::Licence.overlapping.count
    end
  end
end

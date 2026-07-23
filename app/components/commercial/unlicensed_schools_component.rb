# frozen_string_literal: true

module Commercial
  class UnlicensedSchoolsComponent < ApplicationComponent
    def initialize(schools:, **)
      super(**)
      @schools = schools
      @academic_year = Calendar.default_national.current_academic_year
    end

    private

    def licensed_for(school, academic_year = @academic_year)
      return nil unless academic_year

      school.licensed_for_period(academic_year.start_date..academic_year.end_date)
    end

    def badge(school, academic_year = @academic_year)
      licensed_for = licensed_for(school, academic_year)
      Elements::BadgeComponent.new(licensed_for.to_s.humanize, pill: true,
                                                               colour: helpers.period_badge_colour(licensed_for))
    end
  end
end

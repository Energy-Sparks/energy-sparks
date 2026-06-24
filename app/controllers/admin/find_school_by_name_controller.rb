# frozen_string_literal: true

module Admin
  class FindSchoolByNameController < AdminController
    def index
      @schools = find_schools_by_name
      @onboardings = find_onboarding_by_name
    end

    private

    def find_schools_by_name
      if params['query'].present?
        School.search_by_name(params['query']).limit(20)
      else
        []
      end
    end

    def find_onboarding_by_name
      if params['query'].present?
        SchoolOnboarding.incomplete.search_by_school_name(params['query']).limit(20)
      else
        []
      end
    end
  end
end

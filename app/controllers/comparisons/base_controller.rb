module Comparisons
  class BaseController < ApplicationController
    include UserTypeSpecific
    skip_before_action :authenticate_user!

    before_action :filter

    before_action :set_schools
    helper_method :index_params

    def index
      @result = Comparison::ReportService.new(definition: definition).perform
    end

    private

    # Implement in sub-class to return Comparison::ReportDefinition
    def definition
      nil
    end

    def filter
      @filter ||=
        params.permit(:search, :benchmark, :country, :school_type, :funder, school_group_ids: [], school_types: [])
          .with_defaults(school_group_ids: [], school_types: School.school_types.keys)
          .to_hash.symbolize_keys
    end

    def index_params
      filter.merge(anchor: filter[:search])
    end

    def set_schools
      @schools = included_schools
    end

    def included_schools
      # wonder if this can be replaced by a use of the scope accessible_by(current_ability)
      include_invisible = can? :show, :all_schools
      school_params = filter.slice(:school_group_ids, :school_types, :school_type, :country, :funder).merge(include_invisible: include_invisible)

      schools = SchoolFilter.new(**school_params).filter
      schools.select {|s| can?(:show, s) } unless include_invisible
      schools
    end
  end
end

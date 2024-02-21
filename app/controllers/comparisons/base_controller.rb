module Comparisons
  class BaseController < ApplicationController
    include UserTypeSpecific
    skip_before_action :authenticate_user!

    before_action :filter
    before_action :set_schools
    helper_method :index_params
    before_action :set_advice_page
    before_action :set_title

    def index
      @results = load_data
      @charts = create_charts(@results)
    end

    private

    def set_title
      @title = I18n.t(title_key) if title_key
    end

    def title_key
      nil
    end

    def set_advice_page
      @advice_page = AdvicePage.find_by_key(advice_page_key) if advice_page_key
    end

    # Key for the AdvicePage used to link to school analysis
    def advice_page_key
      nil
    end

    # Load the results from the view
    def load_data
      nil
    end

    # Create the chart configuration used to display chart
    def create_charts(_results)
      []
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

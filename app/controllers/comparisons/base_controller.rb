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
      @chart = create_chart(@results)
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
    def create_chart(_results)
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

    # TODO need to improve chart display so it has a proper title and subtitle like our other charts,
    # that will be handled in a new chart component or view
    #
    # Other improvements: disable legend clicking, ensuring colour coding matches what we use elsewhere?
    def create_chart_configuration(config_name:, title: nil, chart_data: {}, series_name: nil, y_axis_label: nil)
      {
        title: title,
        x_axis: chart_data.keys.map(&:name),
        x_axis_ranges: nil,
        x_data: { series_name => chart_data.values },
        y_axis_label: y_axis_label,
        chart1_type: :bar,
        chart1_subtype: :stacked,
        config_name: config_name
      }
    end
  end
end

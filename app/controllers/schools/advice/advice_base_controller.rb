module Schools
  module Advice
    class AdviceBaseController < ApplicationController
      before_action :header_fix_enabled

      load_and_authorize_resource :school
      skip_before_action :authenticate_user!

      before_action :load_advice_page, only: [:insights, :analysis, :learn_more]
      before_action :set_tab_name, only: [:insights, :analysis, :learn_more]
      before_action :check_authorisation, only: [:insights, :analysis, :learn_more]
      before_action :load_recommendations, only: [:insights]
      before_action :check_aggregated_school_in_cache, only: [:insights, :analysis]
      before_action :set_data_warning, only: [:insights, :analysis]

      include AdvicePageHelper
      include SchoolAggregation

      rescue_from StandardError do |exception|
        Rollbar.error(exception, advice_page: advice_page_key, school: @school.name, school_id: @school.id)
        raise if Rails.env.development?
        render 'error'
      end

      def show
        redirect_to url_for([:insights, @school, :advice, advice_page_key])
      end

      def learn_more
        @learn_more = @advice_page.learn_more
      end

      private

      def set_data_warning
        @data_warning = !recent_data?(advice_page_end_date)
      end

      def advice_page_end_date
        @advice_page_end_date ||= AggregateSchoolService.analysis_date(aggregate_school, @advice_page.fuel_type)
      end

      def set_tab_name
        @tab = action_name.to_sym
      end

      def load_advice_page
        @advice_page = AdvicePage.find_by_key(advice_page_key)
      end

      def check_authorisation
        if @advice_page && @advice_page.restricted && cannot?(:read_restricted_advice, @school)
          redirect_to school_advice_path(@school), notice: 'Only an admin or staff user for this school can access this content'
        end
      end

      def load_recommendations
        @activity_types = @advice_page.activity_types
        @intervention_types = @advice_page.intervention_types.limit(3)
      end
    end
  end
end

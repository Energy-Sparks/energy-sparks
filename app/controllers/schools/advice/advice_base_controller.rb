module Schools
  module Advice
    class AdviceBaseController < ApplicationController
      load_and_authorize_resource :school
      skip_before_action :authenticate_user!

      before_action :load_advice_page, only: [:insights, :analysis, :learn_more]
      before_action :set_tab_name, only: [:insights, :analysis, :learn_more]
      before_action :check_authorisation, only: [:insights, :analysis, :learn_more]

      include SchoolAggregation

      def show
        redirect_to url_for([:insights, @school, :advice, advice_page_key])
      end

      def learn_more
        @learn_more = @advice_page.learn_more
        render 'schools/advice/learn_more'
      end

      private

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
    end
  end
end

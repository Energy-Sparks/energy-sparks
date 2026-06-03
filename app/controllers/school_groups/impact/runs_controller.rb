# frozen_string_literal: true

module SchoolGroups
  module Impact
    class RunsController < AdminController
      layout 'group_settings'

      before_action :enable_bootstrap5
      load_and_authorize_resource :school_group
      load_and_authorize_resource :run, class: 'ImpactReport::Run', through: :school_group,
                                        through_association: :impact_report_runs

      def index
        @runs = @runs.order(run_date: :desc)
      end

      def latest
        @run = @runs.latest
        render :show
      end
    end
  end
end

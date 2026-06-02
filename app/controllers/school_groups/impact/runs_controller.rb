# frozen_string_literal: true

module SchoolGroups
  module Impact
    class RunsController < AdminController
      layout 'group_settings'

      before_action :enable_bootstrap5
      load_and_authorize_resource :school_group
      # load_and_authorize_resource :impact_resource_run, class: 'ImpactReport::Run',as: :run, through: :school_group

      def index
        @runs = @school_group.impact_report_runs.order(run_date: :desc)
      end
    end
  end
end

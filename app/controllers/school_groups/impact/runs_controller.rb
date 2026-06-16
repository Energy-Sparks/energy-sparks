# frozen_string_literal: true

module SchoolGroups
  module Impact
    class RunsController < AdminController
      layout 'group_settings'

      before_action :enable_bootstrap5
      load_and_authorize_resource :school_group
      load_and_authorize_resource :run, class: 'ImpactReport::Run', through: :school_group,
                                        through_association: :impact_report_runs, include: :metrics

      def index
        @runs = @runs.latest_first
      end

      def latest
        @run = @runs.latest_first.first
        render :show
      end
    end
  end
end

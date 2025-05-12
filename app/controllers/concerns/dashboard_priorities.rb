module DashboardPriorities
  extend ActiveSupport::Concern

  def setup_priorities(priorities, limit: nil)
    @show_more_management_priorities = limit.nil? ? false : priorities.count > limit
    priorities.includes(:content_version, :find_out_more, :alert, { alert: [:alert_type, { alert_type: :advice_page }] }).by_priority.limit(limit).map do |priority|
      TemplateInterpolation.new(
        priority.content_version,
        with_objects: {
          advice_page: priority.alert.alert_type.advice_page,
          alert: priority.alert,
          alert_type: priority.alert.alert_type,
          find_out_more: priority.alert.alert_type.find_out_more?,
          priority: priority.priority
        },
        proxy: [:colour]
      ).interpolate(
        :management_priorities_title,
        with: priority.alert.template_variables
      )
    end
  end
end

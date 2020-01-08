module DashboardPriorities
  extend ActiveSupport::Concern

  def setup_priorities(priorities, limit: nil)
    @show_more_management_priorities = limit.nil? ? false : priorities.count > limit
    priorities.by_priority.limit(limit).map do |priority|
      TemplateInterpolation.new(
        priority.content_version,
        with_objects: {
          find_out_more: priority.find_out_more,
          priority: priority.priority,
          alert: priority.alert
        },
        proxy: [:colour]
      ).interpolate(
        :management_priorities_title,
        with: priority.alert.template_variables
      )
    end
  end
end

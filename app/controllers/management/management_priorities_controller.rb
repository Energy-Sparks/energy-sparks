module Management
  class ManagementPrioritiesController < ApplicationController
    load_and_authorize_resource :school

    def index
      authorize! :show_management_dash, @school
      @management_priorities = @school.latest_management_priorities.by_priority.limit(site_settings.management_priorities_page_limit).map do |priority|
        TemplateInterpolation.new(
          priority.content_version,
          with_objects: { find_out_more: priority.find_out_more },
          proxy: [:colour]
        ).interpolate(
          :management_priorities_title,
          with: priority.alert.template_variables
        )
      end
    end
  end
end

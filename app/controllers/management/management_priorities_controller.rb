module Management
  class ManagementPrioritiesController < ApplicationController
    include DashboardPriorities

    load_and_authorize_resource :school

    def index
      authorize! :show_management_dash, @school
      @management_priorities = setup_priorities(@school.latest_management_priorities, limit: site_settings.management_priorities_page_limit)
    end
  end
end

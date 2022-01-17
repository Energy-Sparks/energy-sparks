module Schools
  class ManagementTableService
    def initialize(school)
      @school = school
    end

    def management_table
      dashboard_table = @school.latest_management_dashboard_tables.first
      return dashboard_table.table if dashboard_table.present?
    end

    def management_data
      dashboard_table = @school.latest_management_dashboard_tables.first
      return dashboard_table.data if dashboard_table.present?
    end
  end
end

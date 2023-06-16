module SchoolGroups
  class PriorityActionsCsvGenerator
    def initialize(school_group:)
      @school_group = school_group
      @priority_actions = service.priority_actions
      @total_savings = sort_total_savings(service.total_savings)
    end

    def export
      CSV.generate(headers: true) do |csv|
        csv << headers
        @total_savings.each do |alert_type_rating, savings|
          row = []
          row << alert_type_rating.alert_type&.fuel_type&.humanize
          row << alert_type_rating&.current_content&.management_priorities_title&.to_plain_text
          row << savings.schools&.length
          row << ApplicationController.helpers.format_unit(savings&.one_year_saving_kwh, Float) + ' kWh'
          row << '£' + ApplicationController.helpers.format_unit(savings&.average_one_year_saving_gbp, Float)
          row << ApplicationController.helpers.format_unit(savings&.one_year_saving_co2, Float) + ' kg CO2'

          csv << row
        end
      end
    end

    private

    def sort_total_savings(total_savings)
      total_savings.sort { |a, b| b[1].average_one_year_saving_gbp <=> a[1].average_one_year_saving_gbp }
    end

    def service
      @service ||= SchoolGroups::PriorityActions.new(@school_group)
    end

    def headers
      [
        I18n.t('advice_pages.index.priorities.table.columns.fuel_type'),
        '',
        I18n.t('components.breadcrumbs.schools'),
        I18n.t('advice_pages.index.priorities.table.columns.kwh_saving'),
        I18n.t('advice_pages.index.priorities.table.columns.cost_saving'),
        I18n.t('advice_pages.index.priorities.table.columns.co2_reduction')
      ]
    end
  end
end

module SchoolGroups
  class SchoolsPriorityActionCsvGenerator
    def initialize(school_group:, alert_type_rating_ids: [], include_cluster: false)
      @alert_type_rating_ids = alert_type_rating_ids
      @school_group = school_group
      @priority_actions = service.priority_actions
      @total_savings = sort_total_savings(service.total_savings)
      @include_cluster = include_cluster
    end

    def export
      CSV.generate(headers: true) do |csv|
        csv << headers
        @total_savings.each do |alert_type_rating, _savings|
          next unless @alert_type_rating_ids.map(&:to_i).include?(alert_type_rating.id)

          @priority_actions[alert_type_rating].sort {|a, b| a.school.name <=> b.school.name }.each do |saving|
            row = [
              I18n.t("common.#{alert_type_rating.alert_type&.fuel_type}"),
              alert_type_rating.current_content.management_priorities_title.to_plain_text,
              saving.school.name
            ]
            row << saving.school.school_group_cluster_name if @include_cluster
            row += [
              saving.school.number_of_pupils,
              saving.school.floor_area,
              saving.one_year_saving_kwh.to_s,
              '£' + saving.average_one_year_saving_gbp.to_s,
              saving.one_year_saving_co2.to_s
            ]
            csv << row
          end
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
      columns = [
        I18n.t('advice_pages.index.priorities.table.columns.fuel_type'),
        I18n.t('advice_pages.index.priorities.table.columns.description'),
        I18n.t('common.school')
      ]
      columns << I18n.t('school_groups.clusters.labels.cluster') if @include_cluster
      columns += [
        School.human_attribute_name('number_of_pupils'),
        I18n.t('school_groups.labels.floor_area'),
        I18n.t('advice_pages.index.priorities.table.columns.kwh_saving'),
        I18n.t('advice_pages.index.priorities.table.columns.cost_saving'),
        I18n.t('advice_pages.index.priorities.table.columns.co2_reduction')
      ]
      columns
    end
  end
end

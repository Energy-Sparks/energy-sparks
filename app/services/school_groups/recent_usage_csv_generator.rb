module SchoolGroups
  class RecentUsageCsvGenerator
    METRIC_HEADERS = [:change, :usage, :cost, :co2].freeze
    METRICS = [:change, :usage, :cost_text, :co2].freeze

    def initialize(school_group:, schools: school_group.schools.visible, include_cluster: false)
      @school_group = school_group
      @schools = schools
      @include_cluster = include_cluster
    end

    def export
      CSV.generate(headers: true) do |csv|
        csv << headers
        @schools.order(:name).each do |school|
          recent_usage = school&.recent_usage
          row = []
          row << school.name
          row << school.school_group_cluster_name if @include_cluster
          row << school.number_of_pupils
          row << school.floor_area
          row += columns_for_usage(recent_usage)
          csv << row
        end
      end
    end

    private

    def columns_for_usage(recent_usage)
      columns = []
      fuel_types.each do |fuel_type|
        columns << recent_usage&.send(fuel_type)&.week&.start_date
        columns << recent_usage&.send(fuel_type)&.week&.end_date
        # loop first to add all metrics for last week, then last year
        # rubocop:disable Style/CombinableLoops
        METRICS.each do |metric|
          columns << (recent_usage&.send(fuel_type)&.week&.has_data ? recent_usage&.send(fuel_type)&.week&.send(metric) : '')
        end
        METRICS.each do |metric|
          columns << (recent_usage&.send(fuel_type)&.month&.has_data ? recent_usage&.send(fuel_type)&.month&.send(metric) : '')
        end
        METRICS.each do |metric|
          columns << (recent_usage&.send(fuel_type)&.year&.has_data ? recent_usage&.send(fuel_type)&.year&.send(metric) : '')
        end
        # rubocop:enable Style/CombinableLoops
      end
      columns
    end

    def fuel_types
      # Only include electricity, gas and storage heaters fuel types (e.g. exclude solar pv)
      @fuel_types ||= @school_group.fuel_types & [:electricity, :gas, :storage_heaters]
    end

    def headers
      header_row = []
      header_row << I18n.t('common.school')
      header_row << I18n.t('school_groups.clusters.labels.cluster') if @include_cluster
      header_row << School.human_attribute_name('number_of_pupils')
      header_row << I18n.t('school_groups.labels.floor_area')
      fuel_types.each { |fuel_type| header_row += header_columns_for(fuel_type) }
      header_row
    end

    def header_columns_for(fuel_type)
      columns = []
      [:start_date, :end_date].each do |date|
        columns << I18n.t("common.#{fuel_type}") + ' ' + I18n.t(date, scope: 'common.labels')
      end
      [:last_week, :last_month, :last_year].each do |period|
        METRIC_HEADERS.each do |metric|
          columns << I18n.t("common.#{fuel_type}") + ' ' + I18n.t("school_groups.show.metric.#{metric}") + ' ' + I18n.t("common.labels.#{period}")
        end
      end
      columns
    end
  end
end

module SchoolGroups
  class RecentUsageCsvGenerator
    def initialize(school_group:, metric: 'change', include_cluster: false)
      raise unless %w[change usage cost co2].include?(metric)
      @school_group = school_group
      @metric = metric + '_text'
      @include_cluster = include_cluster
    end

    def export
      CSV.generate(headers: true) do |csv|
        csv << headers
        @school_group.schools.visible.order(:name).each do |school|
          recent_usage = school&.recent_usage
          row = []
          row << school.name
          row << school.school_group_cluster_name if @include_cluster
          row << school.number_of_pupils
          row << school.floor_area
          fuel_types.each { |fuel_type| row += columns_for(fuel_type, recent_usage) }
          csv << row
        end
      end
    end

    private

    def columns_for(fuel_type, recent_usage)
      columns = []
      columns << (recent_usage&.send(fuel_type)&.week&.has_data ? recent_usage&.send(fuel_type)&.week&.send(@metric) : '-')
      columns << (recent_usage&.send(fuel_type)&.year&.has_data ? recent_usage&.send(fuel_type)&.year&.send(@metric) : '-')
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
      header_row << School.human_attribute_name('floor_area')
      fuel_types.each { |fuel_type| header_row += header_columns_for(fuel_type) }
      header_row
    end

    def header_columns_for(fuel_type)
      columns = []
      columns << I18n.t("common.#{fuel_type}") + ' ' + I18n.t('common.labels.last_week')
      columns << I18n.t("common.#{fuel_type}") + ' ' + I18n.t('common.labels.last_year')
      columns
    end
  end
end

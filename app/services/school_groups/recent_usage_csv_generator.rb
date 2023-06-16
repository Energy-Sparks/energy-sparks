module SchoolGroups
  class RecentUsageCsvGenerator
    def initialize(school_group:, metric: 'change')
      raise unless %w[change usage cost co2].include?(metric)
      @school_group = school_group
      @metric = metric
    end

    def export
      CSV.generate(headers: true) do |csv|
        csv << headers
        @school_group.schools.visible.order(:name).each do |school|
          recent_usage = school&.recent_usage

          row = []
          row << school.name
          if fuel_types.include?(:electricity)
            if recent_usage&.electricity&.week&.has_data
              row << Nokogiri::HTML(recent_usage&.electricity&.week.send(@metric)).text
              row << Nokogiri::HTML(recent_usage&.electricity&.year.send(@metric)).text
            else
              row << '-'
              row << '-'
            end
          end

          if fuel_types.include?(:gas)
            if recent_usage&.gas&.week&.has_data
              row << Nokogiri::HTML(recent_usage&.gas&.week.send(@metric)).text
              row << Nokogiri::HTML(recent_usage&.gas&.year.send(@metric)).text
            else
              row << '-'
              row << '-'
            end
          end

          if fuel_types.include?(:storage_heaters)
            if recent_usage&.storage_heaters&.week&.has_data
              row << Nokogiri::HTML(recent_usage&.storage_heaters&.week.send(@metric)).text
              row << Nokogiri::HTML(recent_usage&.storage_heaters&.year.send(@metric)).text
            else
              row << '-'
              row << '-'
            end
          end

          csv << row
        end
      end
    end

    private

    def fuel_types
      @fuel_types ||= @school_group.fuel_types
    end

    def headers
      header_row = []
      header_row << I18n.t('common.school')
      if fuel_types.include?(:electricity)
        header_row << I18n.t('common.electricity') + ' ' + I18n.t('common.labels.last_week')
        header_row << I18n.t('common.electricity') + ' ' + I18n.t('common.labels.last_year')
      end
      if fuel_types.include?(:gas)
        header_row << I18n.t('common.gas') + ' ' + I18n.t('common.labels.last_week')
        header_row << I18n.t('common.gas') + ' ' + I18n.t('common.labels.last_year')
      end
      if fuel_types.include?(:storage_heaters)
        header_row << I18n.t('common.storage_heaters') + ' ' + I18n.t('common.labels.last_week')
        header_row << I18n.t('common.storage_heaters') + ' ' + I18n.t('common.labels.last_year')
      end
      header_row
    end
  end
end

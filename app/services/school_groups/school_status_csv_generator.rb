module SchoolGroups
  class SchoolStatusCsvGenerator < BaseSchoolCsvGenerator
    private

    def headers
      header_row = []
      header_row << I18n.t('common.school')
      header_row << I18n.t('common.labels.status')
      header_row << I18n.t('school_groups.clusters.labels.cluster') if @include_cluster
      header_row << I18n.t('common.labels.onboarded_date')
      header_row << I18n.t('common.labels.data_published_date')
      header_row << I18n.t('common.electricity')
      header_row << I18n.t('common.gas')
      header_row << I18n.t('common.storage_heaters')
      header_row << I18n.t('common.solar_pv')
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
      columns
    end

    def generate_rows
      @schools.map do |school|
        [
          school.name,
          school.data_visible? ? I18n.t('common.labels.data_published') : I18n.t('common.labels.visible'),
          *(@include_cluster ? [school.school_group_cluster_name] : []),
          school&.school_onboarding&.onboarding_completed_on&.to_date&.iso8601,
          school&.school_onboarding&.first_made_data_enabled&.to_date&.iso8601,
          school.has_electricity? ? 'Y' : 'N',
          school.has_gas? ? 'Y' : 'N',
          school.has_storage_heaters? ? 'Y' : 'N',
          school.has_solar_pv? ? 'Y' : 'N',
          school.number_of_pupils,
          school.floor_area
        ] + date_columns(school)
      end
    end

    def date_columns(school)
      columns = []
      [:electricity, :gas, :storage_heater].each do |fuel_type|
        method = fuel_type == :storage_heater ? 'has_storage_heaters?' : "has_#{fuel_type}?"
        if school.public_send(method)
          columns << school.configuration.meter_start_date(fuel_type)
          columns << school.configuration.meter_end_date(fuel_type)
        end
      end
      columns
    end
  end
end

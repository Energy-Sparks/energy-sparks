module SchoolGroups
  class SchoolMeterStatusCsvGenerator < BaseSchoolCsvGenerator
    private

    def headers
      header_row = []
      header_row << I18n.t('school_statistics.school_group')
      header_row << I18n.t('common.school')
      header_row << I18n.t('school_groups.clusters.labels.cluster') if @include_cluster
      header_row << I18n.t('advice_pages.index.priorities.table.columns.fuel_type')
      header_row << I18n.t('schools.meters.index.meter')
      header_row << I18n.t('schools.meters.index.name')
      header_row << I18n.t('common.labels.start_date')
      header_row << I18n.t('common.labels.end_date')
      header_row
    end

    def generate_rows
      meters = []
      @schools.map do |school|
        school.meters.active.order(:mpan_mprn).each do |meter|
          meters << [
            school.school_group.name,
            school.name,
            *(@include_cluster ? [school.school_group_cluster_name] : []),
            I18n.t(meter.meter_type, scope: 'common'),
            meter.mpan_mprn,
            meter.name,
            meter.first_validated_reading.iso8601,
            meter.last_validated_reading.iso8601,
          ]
        end
      end
      meters
    end
  end
end

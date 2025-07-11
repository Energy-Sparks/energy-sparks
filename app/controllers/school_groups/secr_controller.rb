# frozen_string_literal: true

module SchoolGroups
  class SecrController < BaseController
    def index
      raise CanCan::AccessDenied unless current_user.admin? || current_user.group_admin?

      set_breadcrumbs(name: I18n.t('school_groups.sub_nav.secr_report'))
      @last_two_academic_year_periods = Periods::FixedAcademicYear.enumerator(
        MeterMonthlySummary.start_date(Time.zone.today, 2), Time.zone.today).to_a.reverse
      @meters = @school_group.meters.active.where('schools.active')
      respond_to do |format|
        format.html
        format.csv do
          type, previous = params[:csv].split('_')
          year = @last_two_academic_year_periods[previous.nil? ? 1 : 0][0].year
          send_data csv_report(type, year),
                    filename: EnergySparks::Filenames.csv("secr-#{type}-#{year}#{(year + 1).to_s.last(2)}")
        end
      end
    end

    private

    def csv_headers
      [t('common.school'),
       t('activerecord.attributes.school.number_of_pupils'),
       'MPXN',
       t('school_groups.secr.csv.meter_serial'),
       t('school_groups.secr.csv.meter_name'),
       t('school_groups.secr.csv.consumption_for_the_year'),
       ((9..12).map { |m| [@last_two_academic_year_periods[0][0].year, m] } +
        (1..8).map { |m| [@last_two_academic_year_periods[0][0].year + 1, m] })
            .map { |year, month| [Date.new(year, month, 1).strftime('%b-%Y'), t('school_groups.secr.csv.quality')] },
       t('school_groups.secr.csv.earliest_validated_reading'),
       t('school_groups.secr.csv.latest_validated_reading')].flatten
    end

    TYPE_MAPPING = { self: :self_consume, export: :export }.stringify_keys.freeze
    private_constant :TYPE_MAPPING

    def csv_report(type, year)
      CSV.generate do |csv|
        csv << csv_headers
        @meters.public_send(type == 'gas' ? :gas : :electricity).order('schools.name, meters.mpan_mprn').each do |meter|
          summary = meter.meter_monthly_summaries.find_by(year:, type: TYPE_MAPPING.fetch(type, :consumption))
          next if summary.nil?

          csv << [
            meter.school.name,
            meter.school.number_of_pupils,
            meter.mpan_mprn,
            meter.meter_serial_number,
            meter.name,
            summary.total.round(2),
            ((8..11).to_a + (0..7).to_a).map do |m|
              [summary.consumption[m]&.round(2), summary.quality[m]&.[](0)&.upcase]
            end,
            meter.amr_validated_readings.minimum(:reading_date),
            meter.amr_validated_readings.maximum(:reading_date)
          ].flatten
        end
      end
    end
  end
end

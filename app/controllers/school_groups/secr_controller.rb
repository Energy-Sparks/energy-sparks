# frozen_string_literal: true

module SchoolGroups
  class SecrController < BaseController
    def index
      raise CanCan::AccessDenied unless current_user.admin? || current_user.group_admin?

      set_breadcrumbs(name: I18n.t('school_groups.sub_nav.secr_report'))
      @start_date = MeterMonthlySummary.start_date(Time.zone.today, 2)
      @meters = @school_group.meters.active.where('schools.active')
      respond_to do |format|
        format.html
        format.csv do
          type = params[:csv]
          send_data csv_report(type), filename: EnergySparks::Filenames.csv("secr-#{type}")
        end
      end
    end

    private

    def csv_headers
      [t('common.school'),
       'MPXN',
       t('school_groups.secr.csv.meter_serial'),
       t('school_groups.secr.csv.meter_name'),
       t('school_groups.secr.csv.consumption_for_the_year'),
       ((9..12).map { |m| [@start_date.year, m] } +
        (1..8).map { |m| [@start_date.year + 1, m] })
            .map { |year, month| [Date.new(year, month, 1).strftime('%b-%Y'), t('school_groups.secr.csv.quality')] },
       t('school_groups.secr.earliest_validated_reading'),
       t('school_groups.secr.latest_validated_reading')].flatten
    end

    TYPE_MAPPING = { self: :self_consume, export: :export }.stringify_keys.freeze
    private_constant :TYPE_MAPPING

    def csv_report(type)
      CSV.generate do |csv|
        csv << csv_headers
        @meters.public_send(type == 'gas' ? :gas : :electricity)
               .order('schools.name, meters.mpan_mprn').each do |meter|
          summary = meter.meter_monthly_summaries.find_by(year: @start_date.year,
                                                          type: TYPE_MAPPING.fetch(type, :consumption))
          next if summary.nil?

          csv << [
            meter.school.name,
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

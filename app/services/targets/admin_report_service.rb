module Targets
  class AdminReportService
    def send_email_report(progress: true, target_data: true)
      progress_report = progress_report_as_csv if progress
      target_data_report = target_data_report_as_csv if target_data
      TargetMailer.with(to: to,
        target_summary: target_summary,
        progress_report: progress_report,
        target_data_report: target_data_report).admin_target_report.deliver_now
    end

    def progress_report_as_csv
      generate_csv_for_school_groups(progress_report_headers) do |csv, school_group|
        service = Targets::SchoolGroupProgressReportingService.new(school_group)
        data = service.report
        data.each do |school_target_progress|
          #rows for all schools
          row = [
            school_group.name,
            school_target_progress.school.name,
            school_target_progress.targets_enabled,
            school_target_progress.enough_data
          ]
          #add 8 more columns: 2x dates, 2x for each fuel type
          progress_summary = school_target_progress.progress_summary
          if progress_summary.present?
            row = add_progress_report_fuel_type_columns(row, progress_summary)
          else
            row += Array.new(8, nil)
          end
          csv << row
        end
      end
    end

    def target_data_report_as_csv
      generate_csv_for_school_groups(target_data_report_headers) do |csv, school_group|
        service = Targets::SchoolGroupTargetDataReportingService.new(school_group)
        data = service.report
        data.each do |school, school_result|
          FUEL_TYPES.each do |fuel_type|
            if school_result[fuel_type].present?
              csv << [
                school_group.name,
                school.name,
                school.visible,
                school.data_enabled,
                fuel_type,
                school_result[fuel_type][:target_set],
                school_result[fuel_type][:holidays],
                school_result[fuel_type][:temperature],
                school_result[fuel_type][:readings],
                school_result[fuel_type][:estimate_needed],
                school_result[fuel_type][:estimate_set],
                school_result[fuel_type][:calculate_synthetic_data]
              ]
            end
          end
        end
      end
    end

    private

    FUEL_TYPES = [:electricity, :gas, :storage_heater].freeze

    def school_groups
      SchoolGroup.all.by_name
    end

    def to
      'operations@energysparks.uk'
    end

    def target_summary
      OpenStruct.new(
        currently_active: SchoolTarget.currently_active.count,
        first_target_sent: SchoolTargetEvent.first_target_sent.count,
        review_target_sent: SchoolTargetEvent.review_target_sent.count
      )
    end

    def generate_csv_for_school_groups(headers)
      CSV.generate do |csv|
        csv << headers
        school_groups.each do |school_group|
          yield csv, school_group
        end
      end
    end

    def target_data_report_headers
      ["Group",
       "School",
       "Visible?",
       "Data Visible?",
       "Fuel type",
       "Target set?",
       "Holidays?",
       "Temperature?",
       "Readings?",
       "Annual estimate needed?",
       "Annual estimate set?",
       "Can calculate synthetic data?"]
    end

    def progress_report_headers
      ["Group",
       "School",
       "Targets Enabled?",
       "Enough Data?",
       "Start Date",
       "Target Date",
       "Electricity Target",
       "Electricity Progress",
       "Gas Target",
       "Gas Progress",
       "Storage Heater Target",
       "Storage Heater Progress"]
    end

    def add_progress_report_fuel_type_columns(row, progress_summary)
      school_target = progress_summary.school_target
      #dates
      row += [school_target.start_date.strftime("%Y-%m-%d"), school_target.target_date.strftime("%Y-%m-%d")]
      #add 2 columns for each fuel type
      row = add_progress_report_fuel_type(row, school_target.electricity, progress_summary.electricity_progress)
      row = add_progress_report_fuel_type(row, school_target.gas, progress_summary.gas_progress)
      row = add_progress_report_fuel_type(row, school_target.storage_heaters, progress_summary.storage_heater_progress)
      row
    end

    def add_progress_report_fuel_type(row, fuel_target, fuel_progress)
      if fuel_target.present?
        row += [
          format_percent_reduction(fuel_target),
          fuel_progress.present? && fuel_progress.progress.present? ? format_target(fuel_progress.progress) : nil
        ]
      else
        row += Array.new(2, nil)
      end
      row
    end

    def format_percent_reduction(target)
      return "0%" if target == 0
      return "-#{target}%"
    end

    def format_target(value)
      FormatEnergyUnit.format(:relative_percent, value, :html, false, true, :target)
    end
  end
end

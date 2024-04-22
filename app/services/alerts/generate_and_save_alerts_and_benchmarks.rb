module Alerts
  class GenerateAndSaveAlertsAndBenchmarks
    def initialize(school:, aggregate_school: nil, benchmark_result_generation_run: nil,
                   framework_adapter: FrameworkAdapter)
      @school = school
      @aggregate_school = aggregate_school || AggregateSchoolService.new(school).aggregate_school
      @benchmark_result_generation_run = benchmark_result_generation_run || BenchmarkResultGenerationRun.create!
      @framework_adapter = framework_adapter
    end

    def perform
      ActiveRecord::Base.transaction do
        @alert_generation_run = AlertGenerationRun.create!(school: @school)
        @benchmark_result_school_generation_run = BenchmarkResultSchoolGenerationRun.create!(school: @school,
                                                                                             benchmark_result_generation_run: @benchmark_result_generation_run)

        relevant_alert_types.each { |alert_type| process_alert_and_benchmarks_for(alert_type) }

        process_custom_periods
      end
    end

    private

    def process_alert_and_benchmarks_for(alert_type)
      if alert_type.class_name == 'AlertImpendingHoliday'
        # AlertImpendingHoliday is a special case where different
        # dates for alert and benchmarks are used
        service = generate_alert_type_run_result_service(
          alert_type: alert_type,
          use_max_meter_date_if_less_than_asof_date: false
        )
        alert_type_run_result = service.perform(Time.zone.today)
        process_alert_type_run_result(alert_type_run_result)

        service = generate_alert_type_run_result_service(
          alert_type: alert_type,
          use_max_meter_date_if_less_than_asof_date: true
        )
        alert_type_run_result = service.perform(Time.zone.today)
        process_benchmark_type_run_result(alert_type_run_result)
      else
        service = generate_alert_type_run_result_service(
          alert_type: alert_type,
          use_max_meter_date_if_less_than_asof_date: alert_type.fuel_type.present?
        )

        alert_type_run_result = service.perform
        process_alert_type_run_result(alert_type_run_result)
        process_benchmark_type_run_result(alert_type_run_result) if alert_type.benchmark
      end
    end

    def generate_alert_type_run_result_service(alert_type:, use_max_meter_date_if_less_than_asof_date:)
      GenerateAlertTypeRunResult.new(
        school: @school,
        aggregate_school: @aggregate_school,
        alert_type: alert_type,
        use_max_meter_date_if_less_than_asof_date: use_max_meter_date_if_less_than_asof_date
      )
    end

    def process_benchmark_type_run_result(alert_type_run_result)
      asof_date = alert_type_run_result.asof_date
      alert_type = alert_type_run_result.alert_type

      alert_type_run_result.error_messages.each do |error_message|
        BenchmarkResultError.create!(benchmark_result_school_generation_run: @benchmark_result_school_generation_run,
                                     asof_date: asof_date, information: error_message, alert_type: alert_type)
      end

      alert_type_run_result.reports.each do |alert_report|
        process_alert_benchmark_report(alert_type, alert_report, asof_date)
      end
    end

    def process_alert_benchmark_report(alert_type, alert_report, asof_date)
      if alert_report.valid
        if alert_report.benchmark_data.present?
          BenchmarkResult.create!(
            benchmark_result_school_generation_run: @benchmark_result_school_generation_run,
            asof: asof_date,
            alert_type: alert_type,
            results: BenchmarkResult.convert_for_storage(alert_report.benchmark_data),
            results_cy: BenchmarkResult.convert_for_storage(alert_report.benchmark_data_cy)
          )
        end
      else
        BenchmarkResultError.create!(benchmark_result_school_generation_run: @benchmark_result_school_generation_run,
                                     asof_date: asof_date, information: "Relevance: #{alert_report.relevance}", alert_type: alert_type)
      end
    end

    def relevant_alert_types
      RelevantAlertTypes.new(@school).list
    end

    def process_alert_type_run_result(alert_type_run_result, alert_attributes: {})
      asof_date = alert_type_run_result.asof_date
      alert_type = alert_type_run_result.alert_type

      alert_type_run_result.error_messages.each do |error_message|
        AlertError.create!(alert_generation_run: @alert_generation_run, asof_date: asof_date,
                           information: error_message, alert_type: alert_type)
      end

      alert_type_run_result.reports.each do |alert_report|
        process_alert_report(alert_type, alert_report, asof_date, alert_attributes)
      end
    end

    def process_alert_report(alert_type, alert_report, asof_date, alert_attributes)
      if alert_report.valid
        Alert.create(AlertAttributesFactory.new(@school, alert_report, @alert_generation_run, alert_type,
                                                asof_date).generate.merge(**alert_attributes))
      else
        AlertError.create!(alert_generation_run: @alert_generation_run, asof_date: asof_date,
                           information: "INVALID. Relevance: #{alert_report.relevance}", alert_type: alert_type)
      end
    end

    def process_custom_periods
      alert_types = [AlertConfigurablePeriodElectricityComparison, AlertConfigurablePeriodGasComparison,
                     AlertConfigurablePeriodStorageHeaterComparison].filter_map do |alert_class|
        alert_type = AlertType.find_by(class_name: alert_class.name)
        alert_type && @school.fuel_type?(alert_type.fuel_type) ? alert_type : nil
      end
      Comparison::Report.where.not(custom_period: nil).find_each do |report|
        alert_types.each do |alert_type|
          analysis_date = AggregateSchoolService.analysis_date(@aggregate_school, alert_type.fuel_type)
          result = AlertTypeRunResult.generate_alert_report(alert_type, analysis_date, @school) do
            Adapters::AnalyticsAdapter
              .new(alert_type: alert_type,
                   analysis_date: analysis_date,
                   school: @school,
                   aggregate_school: @aggregate_school,
                   use_max_meter_date_if_less_than_asof_date: true)
              .report(alert_configuration: report.to_alert_configuration)
          end
          process_alert_type_run_result(result, alert_attributes: { reporting_period: :custom,
                                                                    custom_period: report.custom_period })
        end
      end
    end
  end
end

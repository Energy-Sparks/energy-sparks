namespace :after_party do
  desc 'Deployment task: migrate_benchmark_groups'
  task migrate_benchmark_groups: :environment do
    puts "Running deploy task 'migrate_benchmark_groups'"

    position = 0
    Benchmarking::BenchmarkManager::CHART_TABLE_GROUPING.each do |key, benchmarks|
      i18n_scope = "analytics.benchmarking.chart_table_grouping.#{key}"

      title_en = I18n.t(:title, scope: i18n_scope, locale: :en)

      report_group = Comparison::ReportGroup.i18n.find_or_initialize_by(title: title_en)
      report_group.description_en = I18n.t(:description, scope: i18n_scope, locale: :en)

      report_group.title_cy = I18n.t(:title, scope: i18n_scope, locale: :cy)
      report_group.description_cy = I18n.t(:description, scope: i18n_scope, locale: :cy)
      report_group.position = position
      position+=1

      benchmarks.each do |benchmark|
        report = Comparison::Report.fetch(benchmark)
        report_group.reports << report unless report_group.reports.include?(report)
      end

      report_group.save!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
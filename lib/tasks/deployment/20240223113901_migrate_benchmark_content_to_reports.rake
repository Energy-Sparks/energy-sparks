namespace :after_party do
  desc 'Deployment task: migrate_benchmark_content_to_reports'
  task migrate_benchmark_content_to_reports: :environment do
    puts "Running deploy task 'migrate_benchmark_content_to_reports'"

    # get all benchmarks for all user types
    # we aren't making use of the benchmark group information here, might we need this at some point?
    benchmark_groups = Benchmarking::BenchmarkManager.structured_pages(user_role: :admin)
    benchmarks = benchmark_groups.inject({}) { |hash, group| hash.merge(group[:benchmarks]) }

    benchmarks.each_key do |key|
      # If we wanted to include the caveat text etc we could use this instead for intro text:
      # benchmark_instance = Benchmarking::BenchmarkContentManager.new(nil).send(:content_handler, nil, key, false)
      # report.introduction_en = benchmark_instance.send(:introduction_text)

      report = Comparison::Report.find_or_initialize_by(key: key)
      report.public = !Benchmarking::BenchmarkManager.chart_table_config(key)[:admin_only]

      # This benchmark has the wrong key for the introduction text (works though because analytics also uses this key)
      intro_key = (key == :jan_august_2022_2023_energy_comparison ? :jan_august_2023_2023_energy_comparison : key)

      I18n.with_locale(:en) do
        report.title_en = I18n.t("analytics.benchmarking.chart_table_config.#{key}")
        report.introduction_en = I18n.t("analytics.benchmarking.content.#{intro_key}.introduction_text_html")
      end
      I18n.with_locale(:cy) do
        report.title_cy = I18n.t("analytics.benchmarking.chart_table_config.#{key}")
        report.introduction_cy = I18n.t("analytics.benchmarking.content.#{intro_key}.introduction_text_html")
      end

      report.save!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

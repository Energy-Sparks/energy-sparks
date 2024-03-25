namespace :after_party do
  desc 'Deployment task: import_footnotes'
  task import_footnotes: :environment do
    puts "Running deploy task 'import_footnotes'"


    def import_footnote(label, key, i18n_key)
      footnote = Comparison::Footnote.find_or_initialize_by(key: key)
      footnote.label = label
      footnote.description_en = Loofah.fragment(I18n.t(i18n_key, locale: :en)).text.gsub(/\(\*\d\) /, '').gsub(/\s+/, ' ')
      footnote.description_cy = Loofah.fragment(I18n.t(i18n_key, locale: :cy)).text.gsub(/\(\*\d\) /, '').gsub(/\s+/, ' ')
      footnote.save!
    end

    import_footnote('1', 'electricity_change_rows', 'analytics.benchmarking.content.footnotes.electricity.change_rows_text') # params: period_type_string
    import_footnote('1', 'gas_change_rows', 'analytics.benchmarking.content.footnotes.gas.change_rows_text') # params: period_type_string, schools_to_sentence

    import_footnote('2', 'electricity_infinite_increase', 'analytics.benchmarking.content.footnotes.electricity.infinite_increase_school_names_text') # params: period_type_string
    import_footnote('2', 'gas_infinite_increase', 'analytics.benchmarking.content.footnotes.gas.infinite_increase_school_names_text') # params: period_type_string

    import_footnote('3', 'electricity_infinite_decrease', 'analytics.benchmarking.content.footnotes.electricity.infinite_decrease_school_names_text') # params: period_type_string
    import_footnote('3', 'gas_infinite_decrease', 'analytics.benchmarking.content.footnotes.gas.infinite_decrease_school_names_text') # params: period_type_string

    import_footnote('5', 'tariff_changed_last_year', 'analytics.benchmarking.configuration.the_tariff_has_changed_during_the_last_year_html')
    import_footnote('6', 'tariff_changed_in_period', 'analytics.benchmarking.content.footnotes.rate_changed_in_period') # change_gbp_current_header

    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

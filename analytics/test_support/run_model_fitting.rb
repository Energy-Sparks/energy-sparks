class RunModelFitting < RunCharts

  private def excel_variation; '- regression modelling' end

  def run(control)
    page_config = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[:heating_model_fitting]
    @school.all_heat_meters.uniq.each do |meter|
      puts "Doing #{@school.name} #{meter.mpan_mprn}"
      run_single_dashboard_page(page_config, meter.mpan_mprn)
    end
    save_to_excel
    write_html('-regression')
    # save_chart_calculation_times
    report_calculation_time(control)
    CompareChartResults.new(control[:compare_results], @school.name).compare_results(all_charts)
    # log_results
  end

  def run_single_dashboard_page(single_page_config, mpan_mprn)
    puts "Running model fitting charts and advice for #{mpan_mprn}"
    single_page_config[:charts].each do |chart_name|
      meter_override = {meter_definition: mpan_mprn}
      run_chart(mpan_mprn.to_s, chart_name, override: meter_override)
    end
  end
end

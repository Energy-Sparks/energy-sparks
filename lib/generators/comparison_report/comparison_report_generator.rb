class ComparisonReportGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  desc 'Generates a comparison report with the given NAME.'

  def generate_scenic_view
    if File.exist?("db/views/#{file_path}_v01.sql")
      if yes?("It looks like db/views/#{file_path}_v01.sql has already been generated. Do you want to create the next version?")
        generate 'scenic:view', file_name
      end
    else
      generate 'scenic:view', file_name
    end
  end

  def create_controller
    # Benchmarking::BenchmarkManager.chart_table_config(file_name)
    template 'controller.rb.tt', "app/controllers/comparisons/#{file_path}_controller.rb"
  end

  def create_model
    template 'model.rb.tt', "app/models/comparison/#{file_path}.rb"
  end

  def create_view
    template '_table.html.erb.tt', "app/views/comparisons/#{file_path}/_table.html.erb"
    template '_table.csv.erb.tt', "app/views/comparisons/#{file_path}/_table.csv.erb"
  end

  def create_spec
    template 'system_spec.rb.tt', "spec/system/comparisons/#{file_path}_spec.rb"
  end

  def add_route
    route "resources :#{file_name}, only: [:index]", namespace: :comparisons
  end
end

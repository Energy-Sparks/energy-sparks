class ComparisonReportGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  desc 'Generates a comparison report with the given NAME.'

  def generate_scenic_view
    file = "db/views/#{file_name.pluralize}_v01.sql"
    if File.exist?(file)
      if yes?("It looks like #{file} has already been generated. Do you want to create the next version?")
        generate 'scenic:view', file_name
      end
    else
      generate 'scenic:view', file_name
    end
  end

  def create_controller
    template 'controller.rb.tt', "app/controllers/comparisons/#{file_path}_controller.rb"
  end

  def create_model
    template 'model.rb.tt', "app/models/comparison/#{file_path}.rb"
  end

  def create_view
    template '_table.html.erb.tt', "app/views/comparisons/#{file_path}/_table.html.erb"
    template '_table.csv.ruby.tt', "app/views/comparisons/#{file_path}/_table.csv.ruby"
  end

  def create_spec
    template 'system_spec.rb.tt', "spec/system/comparisons/#{file_path}_spec.rb"
  end

  def add_route
    route "resources :#{file_name}, only: [:index]", namespace: :comparisons
  end
end

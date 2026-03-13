# frozen_string_literal: true

task scss_colours: :environment do
  template_path = Rails.root.join('app/assets/stylesheets/colours.scss.erb')
  output_path   = Rails.root.join('app/assets/stylesheets/colours.scss')

  # FileUtils.mkdir_p(Rails.root.join('tmp'))

  template = ERB.new(File.read(template_path))
  File.write(output_path, template.result(binding))

  puts "Generated #{output_path}"
end

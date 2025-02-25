#!/usr/bin/env ruby

require 'fileutils'

# Define a method to convert snake_case to CamelCase
class String
  def camelize
    split('_').map(&:capitalize).join
  end

  def woof
    gsub(/(^[ ]|[ ]$)/,'')
  end
end

directory = '.'

erb_files = Dir.glob("#{directory}/app/components/**/*.erb")

erb_files.each do |file|
  content = File.read(file)

  #THIS VERSION 4
  new_content = content.gsub(/<%= component\s+['"]([a-z_\/]+)['"],\h*(.*?)\h*(do\s*\|?.*?\|?\s*)?\h*%>/m) do
    component_path = Regexp.last_match(1)
    params = Regexp.last_match(2)
    block = Regexp.last_match(3)

    # Convert component_path to CamelCase
    component_name = component_path.split('/').map(&:camelize).join('::') + 'Component'

    # Construct the replacement string
    if block
      "<%= render #{component_name}.new(#{params.woof}) #{block.woof} %>"
    else
      "<%= render #{component_name}.new(#{params.woof}) %>"
    end
  end

  # Write changes to the file only if modifications were made
  if new_content != content
    File.write(file, new_content)
    puts "Updated #{file}"
  end
end
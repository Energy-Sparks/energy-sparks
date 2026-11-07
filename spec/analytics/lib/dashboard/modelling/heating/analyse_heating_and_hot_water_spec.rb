# frozen_string_literal: true

require 'rails_helper'
require 'open3'

RSpec.describe AnalyseHeatingAndHotWater do
  let(:heating_directory) { Rails.root.join('analytics/lib/dashboard/modelling/heating') }
  let(:loading_script) do
    <<~'RUBY'
      require 'active_support/all'
      require 'zeitwerk'
      require ARGV.fetch(1)

      module Logging
      end

      directory = ARGV.fetch(0)
      files = Dir.glob(File.join(directory, '**/*.rb')).sort
      if ARGV.fetch(2) == 'zeitwerk'
        loader = Zeitwerk::Loader.new
        loader.inflector = Class.new do
          def camelize(basename, _abspath)
            basename.camelize
          end
        end.new
        loader.push_dir(directory)
        loader.setup
        loader.eager_load
      else
        files.reverse! if ARGV.fetch(2) == 'reverse'
        files.each { |file| require file }
      end

      files.each do |file|
        relative_path = file.delete_prefix(directory + '/').delete_suffix('.rb')
        constant_name = relative_path.camelize
        raise "Missing constant #{constant_name}" unless constant_name.constantize.is_a?(Module)
      end
    RUBY
  end

  it 'defines each constant in its matching namespace and file' do
    heating_directory.glob('**/*.rb').each do |file|
      constant_name = file.relative_path_from(heating_directory).to_s.delete_suffix('.rb').camelize

      expect(Object.const_source_location(constant_name).first).to eq(file.to_s), constant_name
    end
  end

  %w[recursive reverse zeitwerk].each do |load_order|
    it "loads independently of the application using #{load_order} loading" do
      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, '-e', loading_script, heating_directory.to_s,
        Rails.root.join('config/initializers/inflections.rb').to_s, load_order
      )

      expect(status.success?).to be(true), stderr
    end
  end
end

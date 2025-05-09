require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'
# standalone script to statistically analyse meter attributes for
# documentation purposes

module Logging
  @logger = Logger.new('log/meter attribute analyser ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :info
end

meter_attributes_by_type = {}

school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data

school_names = SchoolFactory.instance.school_file_list(source_db, school_name_pattern_match)

school_names.each do |school_name|
  begin
    school = SchoolFactory.instance.load_school(source_db, school_name, cache: false)

    school.all_meters.each do |meter|
      meter.meter_attributes.each do |meter_attribute_name, attribute|
        meter_attribute_name = :solar_pv_export_max if meter_attribute_name == :solar_pv && attribute.any?{ |h| h.key?(:maximum_export_level_kw) }
        if %i[meter_corrections aggregation function].include?(meter_attribute_name)
          meter_attribute_names = attribute.map do |att|
            att = att.keys[0] if att.is_a?(Hash)
            "#{meter_attribute_name}:#{att}"
          end
        else
          meter_attribute_names = [meter_attribute_name]
        end
        meter_attribute_names.each do |name|
          meter_attributes_by_type[name] ||= Array.new

          key = { school_name: school_name, mpxn: meter.mpxn }
          meter_attributes_by_type[name].push(key)
        end
      end
    end
  rescue Exception => e
    puts "School #{school_name} failed to load #{e.message}"
  end
end

meter_attributes_by_type.each do |attribute_name, school_meters|
  banner_length = 160 - 30 - attribute_name.length
  puts "#{'=' * 30}#{attribute_name}#{'=' * banner_length}"
  puts
  if %i[economic_tariff accounting_tariffs].include?(attribute_name)
    puts "Too many to display"
  else
    school_meters.uniq.each_slice(4) do |grouped_meter_info|
      grouped_meter_info.each do |meter_info|
        print sprintf('%-20.20s %-20.20s', meter_info[:school_name], meter_info[:mpxn])
      end
      puts
    end
  end
  puts
end


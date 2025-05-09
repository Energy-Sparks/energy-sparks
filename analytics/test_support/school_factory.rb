# School Factory: deals with getting school, meter data from different sources:
class SchoolFactory
  include Singleton

  def self.storage_heater_schools
    [
      'catsfield*',
      'combe-down*',
      'inver-pri*',
      'mallaig-high*',
      'marksbury*',
      'miller-ac*',
      'pennyland*',
      'plumpton*',
      'st-julian-s-church*',
      'stanton*',
      'tomnacross*'
    ]
  end

  def school_file_list(source, school_name_pattern_match)
    matches = [school_name_pattern_match].flatten
    matching_yaml_files_in_directory(config[source][:file_prefix], matches)
  end

  def load_school(source, filename_prefix, meter_attributes_overrides: {}, cache: true)
    @school_cache ||= {}
    return @school_cache[filename_prefix] if @school_cache.key?(filename_prefix)

    garbage_collect(filename_prefix) unless cache

    school = load_and_build_school(source, filename_prefix, meter_attributes_overrides)

    @school_cache[filename_prefix] = school if cache

    school
  end

  private

  def config
    {
      aggregated_meter_collection: {
        file_prefix:  'aggregated-meter-collection-',
        validate:     false,
        aggregate:    false
      },
      validated_meter_collection: {
        file_prefix:  'aggregated-meter-collection-',
        validate:     false,
        aggregate:    true
      },
      unvalidated_meter_collection: {
        file_prefix:  'unvalidated-meter-collection',
        validate:     true,
        aggregate:    true
      },
      unvalidated_meter_data_bulk_load_dont_process: {
        file_prefix:  'unvalidated-data-',
        validate:     false,
        aggregate:    false,
        dont_load:    true
      },
      unvalidated_meter_data: {
        file_prefix:  'unvalidated-data-',
        validate:     true,
        aggregate:    true
      }
    }
  end

  def load_and_build_school(source, filename_prefix, meter_attributes_overrides)
    school = load_meter_collections(filename_prefix, config[source][:file_prefix], config[source][:dont_load])
    return nil if config[source][:dont_load] == true

    school = build_meter_collection(school, meter_attributes_overrides: meter_attributes_overrides)
    validate_and_aggregate(school, source)
    school
  end

  def garbage_collect(name)
    puts 'Garbage collecting'
    GC.start
  end

  def validate_and_aggregate(school, source)
    AggregateDataService.new(school).validate_meter_data if config[source][:validate]
    AggregateDataService.new(school).aggregate_heat_and_electricity_meters if config[source][:aggregate]
    school
  end

  def matching_yaml_files_in_directory(file_type, school_pattern_matches)
    filenames = school_pattern_matches.map do |school_pattern_match|
      match = file_type + school_pattern_match + '.yaml'
      Dir[match, base: meter_collection_directory]
    end.flatten.uniq
    files = filenames.map { |filename| filename.gsub(file_type,'').gsub('.yaml','') }
    compact_print(file_type, files, meter_collection_directory)
    files
  end

  def compact_print(file_type, files, path)
    puts "Loading #{files.length} of type #{file_type} from #{path}:"
    grouped_short_names = files.map { |f| sprintf('%-14.14s', f) }.each_slice(10).to_a
    grouped_short_names.each do |group|
      puts group.join(' ')
    end
  end

  def load_meter_collections(school_filename, file_type, dont_load)
    school = nil
    yaml_filename     = build_filename(school_filename, file_type, '.yaml')
    marshal_filename  = build_filename(school_filename, file_type, '.marshal')

    if !File.exist?(marshal_filename) || File.mtime(yaml_filename) > File.mtime(marshal_filename)
      RecordTestTimes.instance.record_time(school_filename, 'yamlload', ''){
        school = YAML.unsafe_load_file(yaml_filename)
      }
      # save to marshal for subsequent speedy load
      File.open(marshal_filename, 'wb') { |f| f.write(Marshal.dump(school)) }
    else
      RecordTestTimes.instance.record_time(school_filename, 'marshalload', ''){
        school = Marshal.load(File.open(marshal_filename)) unless dont_load == true
      }
    end
    school
  end

  def build_filename(school_filename, file_type, extension)
    filename = file_type + school_filename + extension
    File.join(meter_collection_directory, filename)
  end

  def meter_collection_directory
    TestDirectory.instance.meter_collection_directory
  end

  def split_pseudo_and_non_pseudo_override_attributes(meter_attributes_overrides)
    pseudo_meter_attributes = meter_attributes_overrides.select { |k, _v| k.is_a?(Symbol) }
    meter_attributes        = meter_attributes_overrides.select { |k, _v| k.is_a?(Integer) }
    [pseudo_meter_attributes, meter_attributes]
  end

  def build_meter_collection(data, meter_attributes_overrides: {})
    pseudo_meter_overrides, _meter_overrides = split_pseudo_and_non_pseudo_override_attributes(meter_attributes_overrides)
    meter_attributes = data[:pseudo_meter_attributes]

    MeterCollectionFactory.new(
      temperatures:           data[:schedule_data][:temperatures],
      solar_pv:               data[:schedule_data][:solar_pv],
      solar_irradiation:      data[:schedule_data][:solar_irradiation],
      grid_carbon_intensity:  data[:schedule_data][:grid_carbon_intensity],
      holidays:               data[:schedule_data][:holidays]
    ).build(
      school_data:                data[:school_data],
      amr_data:                   data[:amr_data],
      meter_attributes_overrides: meter_attributes_overrides,
      pseudo_meter_attributes:    meter_attributes.merge(pseudo_meter_overrides)
    )
  end
end

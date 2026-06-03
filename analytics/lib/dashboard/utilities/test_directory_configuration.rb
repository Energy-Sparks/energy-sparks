# manages test directory structure, creating directories as necessary
# asks for environment variable 'ANALYTICSTESTDIR' to be set, if not already
# then if run again creates meter collection directory, to which the user needs
# to copy files
class TestDirectory
  include Singleton
  class EnvironmentVariableNotSet < StandardError; end

  def base_dir
    base_dir_env_variable
  end

  def meter_collection_directory
    unless File.exist?(meter_collection_dir_path)
      make_dir(meter_collection_dir_path)
      puts "Please add meter collection files to #{meter_collection_dir_path}"
    end
    meter_collection_dir_path
  end

  def test_directory_name(test_name_type)
    directory_name = test_base_dir_name(test_name_type)
    create_test_sub_directories(test_name_type)
    directory_name
  end

  def results_directory(test_name_type)
    dir_type(test_name_type, :readable_results)
  end

  def base_comparison_directory(test_name_type)
    dir_type(test_name_type, :base_comparison)
  end

  def results_comparison_directory(test_name_type)
    dir_type(test_name_type, :comparison_results)
  end

  def log_directory
    make_dir(File.join(base_dir, 'log'))
  end

  def timing_directory
    make_dir(File.join(base_dir, 'timing'))
  end

  private

  def sub_directories
    {
      base_comparison:    'Base',
      comparison_results: 'New',
      readable_results:   'Results',
      log:                'log'
    }
  end

  def meter_collection_dir_name
    'MeterCollections'
  end

  def dir_type(test_name_type, type)
    directory_name = test_base_dir_name(test_name_type)
    create_test_sub_directories(test_name_type)
    File.join(directory_name, sub_directories[type])
  end

  def test_scripts
    {
      windows: [ 'delete_base.bat', 'delete_new.bat', 'copy_new_to_base.bat' ]
    }
  end

  def test_base_dir_name(test_name_type)
    dir_name = File.join(base_dir, test_name_type)
    make_dir(dir_name)
  end

  def base_dir_env_variable
    'analytics/test_output'
  end

  def meter_collection_dir_path
    File.join(base_dir, meter_collection_dir_name)
  end

  def create_test_sub_directories(test_name_type)
    test_dir = test_base_dir_name(test_name_type)
    make_dir(test_dir)

    sub_directories.values.each do |sub_directory_name|
      sub_dir_path = File.join(test_dir, sub_directory_name)
      make_dir(File.join(test_dir, sub_directory_name))
      create_copying_scripts(test_dir, :windows) if windows?
    end
  end

  def make_dir(dir_name)
    unless File.exist?(dir_name)
      puts "Creating directory #{dir_name}"
      Dir.mkdir(dir_name)
    end
    dir_name
  end

  def windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def create_copying_scripts(test_dir, os)
    scripts = test_scripts[os]
    scripts.each do |script|
      target_file_name = File.join(test_dir, script)

      unless File.exist?(target_file_name)
        puts "Creating test support script #{target_file_name}"
        source_file_name = File.join('./test_support', script)
        FileUtils.cp(source_file_name, target_file_name)
      end
    end
  end
end

class FileWriter
  include Logging
  attr_reader :filename_stub
  def initialize(filename_stub, override: false, archive: false)
    @filename_stub = filename_stub
    @override = override
  end

  def save(data)
    save_marshal_file(data)
    save_yaml_file(data)
  end

  def load
    data = nil
    puts "Loading ? #{filename_stub}"
    if !File.exist?(yaml_filename)
      return {}
    elsif File.exist?(marshal_filename) && File.mtime(marshal_filename) > File.mtime(yaml_filename)
      data = load_marshal_file
    elsif File.exist?(yaml_filename)
      data = load_yaml_file
      save_marshal_file(data)
    end
    data
  end

  def save_yaml_file(data)
    File.open(yaml_filename, 'w') { |f| f.write(YAML.dump(data)) }
  end

  def exists?
    File.exist?(marshal_filename) || File.exist?(yaml_filename)
  end

  private

  def save_marshal_file(data)
    File.open(marshal_filename, 'wb') { |f| f.write(Marshal.dump(data)) }
  end

  def load_marshal_file(filename = marshal_filename)
    data = nil
    bm = Benchmark.realtime {
      return nil unless File.file?(filename)
      data = Marshal.load(File.open(filename))
    }
    logger.info "Loading #{filename} took #{bm.round(5)}"
    puts "Loading #{filename} took #{bm.round(5)}"
    data
  end

  def load_yaml_file(filename = yaml_filename)
    data = nil
    bm = Benchmark.realtime {
      puts "Loading YAML file #{filename}"
      return nil unless File.file?(filename)
      data = YAML::load_file(filename)
    }
    logger.info "Loading #{filename} took #{bm.round(5)}"
    puts "Loading #{filename} took #{bm.round(5)}"
    data
  end

  def yaml_filename
    @filename_stub + '.yaml'
  end

  def marshal_filename
    @filename_stub + '.marshal'
  end
end

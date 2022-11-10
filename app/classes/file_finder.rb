class FileFinder
  def initialize(path)
    @path = path
  end

  def find(name)
    search_dir(@path) do |filename|
      return filename if filename.include?(name)
    end
  end

  private

  def search_dir(dir, &block)
    return unless File.exist?(dir)
    Dir.each_child(dir) do |d|
      name = File.join(dir, d)
      if File.directory?(name)
        search_dir(name, &block)
      else
        yield name
      end
    end
  end
end

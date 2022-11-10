class FileFinder
  def find(path, name)
    search_dir(path) do |filename|
      return filename if filename.include?(name)
    end
  end

  private

  def search_dir(dir)
    return unless File.exist?(dir)
    Dir.each_child(dir) do |d|
      name = File.join(dir, d)
      if File.directory?(name)
        search_dir(name, &callback)
      elsif block_given?
        yield name
      end
    end
  end
end

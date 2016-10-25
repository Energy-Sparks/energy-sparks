module ApplicationHelper
  def active(bool = true)
    bool ? '' : 'bg-warning'
  end

  def html_from_markdown(folder, file)
    folder_dir = Rails.root.join('markdown_pages').join(folder.to_s)
    if File.exist? folder_dir
      file_name = file.nil? ? 'default.md' : file + '.md'
      full_path = folder_dir.join file_name
      return "Sorry, we couldn't find that page. [File not found]" unless File.exist? full_path
      render_markdown(full_path)
    else
      "Sorry, we couldn't find that page. [Folder not found]"
    end
  end

  def render_markdown(path)
    contents = File.read(path)
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer, autolink: true)
    markdown.render(contents).html_safe
  end
end

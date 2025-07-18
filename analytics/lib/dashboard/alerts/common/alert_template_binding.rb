# separate out alert variable binding
require 'erb'

class AlertTemplateBinding
  def initialize(template, binding_variables, format = :html)
    @template = template
    @binding_variables = binding_variables
    @format = format
  end

  # bind alert variables to template
  def bind
    b = binding_from_hash(@binding_variables)
    results = ERB.new(@template, nil, '-').result(b)
    results = strip_html(results) if @format == :text
    results
  end

  private

  def clean_binding
    binding
  end

  def binding_from_hash(**vars)
    b = clean_binding
    vars.each do |k, v|
      b.local_variable_set k, v
    end
    return b
  end

  private def strip_html(str)
    # avoid using sanitize gem if possible
    str = str.gsub(/<\/p>/,"ZZZZZ") # keep </p> for \n
    str = str.gsub(/<\/?[^>]*>/, '') # strip out html tags
    str = str.gsub(/\s*\n/, '') # remove blank lines
    str = str.gsub(/\s+/, ' ') # remove multiple spaces
    str = str.gsub(/ZZZZZ/,"\n") # put </p> back as \n
    str.squeeze("\n")
  end
end

class AlertRenderTable
  def initialize(header, data)
    @header = header
    @data = data
  end

  def render(format = :html)
    if format == :html
      render_html
    else
      render_text
    end
  end

  def render_html
    template = %{
      <table class="table table-striped table-sm">
        <thead>
          <tr class="thead-dark">
            <% @header.each do |header_titles| %>
              <th scope="col"> <%= header_titles.to_s %> </th>
            <% end %>
          </tr>
        </thead>
        <tbody>
          <% @data.each do |row| %>
            <tr>
              <% row.each do |val| %>
                <td> <%= val %> </td>
              <% end %>
            </tr>
          <% end %>
        </tbody>
      </table>
    }.gsub(/^  /, '')

    html = ERB.new(template)
    html.result(binding).gsub(/^\s*$/,'').gsub(/\n{2,}/, '') # .gsub(/^\s*$/,'').gsub(/\n{2,}/, '').gsub(/\s{2,}/,'')
  end

  def render_text
    [@header] + @data
  end
end

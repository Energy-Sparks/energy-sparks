require 'mustache'
require 'closed_struct'

class TemplateInterpolation
  def initialize(object, with_objects: {}, proxy: [], render_with: Mustache.new)
    @object = object
    @with_objects = with_objects
    @proxy = proxy
    @render_with = render_with
  end

  def interpolate(*fields, with: {})
    base_methods = { template_variables: with }.merge(@with_objects)
    with_proxied_objects = @proxy.inject(base_methods) do |collection, field|
      collection[field] = @object.send(field)
      collection
    end
    templated = fields.inject(with_proxied_objects) do |collection, field|
      template = @object.send(field) || ""
      collection[field] = if template.is_a?(ActionText::RichText)
                            process_rich_text_template(template, with)
                          else
                            process_string_template(template, with)
                          end
      collection
    end
    ClosedStruct.new(templated)
  end

  def variables(*fields)
    from_templates = fields.inject([]) do |variables, field|
      variables + get_variables(@object.send(field))
    end
    from_templates.uniq.map {|variable| variable.gsub('gbp', '£') }
  end

private

  def process_string_template(template, variables)
    @render_with.render(template, variables)
  end

  def process_rich_text_template(template, variables)
    # ActionText content wraps up content in a wrapper div, usually <div class="trix-content"></div>
    # fragment returns the content without the wrapper
    template_string = template.body.fragment.to_s
    template.body = ActionText::Content.new(process_string_template(template_string, variables))
    template
  end

  def get_variables(template)
    mustache = @render_with
    mustache.template = template_as_string(template)
    mustache.template.tags
  end

  def template_as_string(template)
    template.is_a?(ActionText::RichText) ? template.body.fragment.to_s : template
  end
end

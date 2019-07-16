# frozen_string_literal: true

require 'mustache'
require 'closed_struct'

class TemplateInterpolation
  def initialize(object, with_objects: {}, proxy: [])
    @object = object
    @with_objects = with_objects
    @proxy = proxy
  end

  def interpolate(*fields, with: {})
    pre_defined = @proxy.each_with_object(@with_objects) do |field, collection|
      collection[field] = @object.send(field)
    end
    templated = fields.each_with_object(pre_defined) do |field, collection|
      collection[field] = process(@object.send(field), with)
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

  def process(template, variables)
    Mustache.render(template, variables)
  end

  def get_variables(template)
    mustache = Mustache.new
    mustache.template = template
    mustache.template.tags
  end
end

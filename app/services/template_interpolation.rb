require 'mustache'
require 'closed_struct'

class TemplateInterpolation
  def initialize(object, with_objects: {}, proxy: [])
    @object = object
    @with_objects = with_objects
    @proxy = proxy
  end

  def interpolate(*fields, with: {})
    pre_defined = @proxy.inject(@with_objects) do |collection, field|
      collection[field] = @object.send(field)
      collection
    end
    templated = fields.inject(pre_defined) do |collection, field|
      collection[field] = process(@object.send(field), with)
      collection
    end
    ClosedStruct.new(templated)
  end

private

  def process(template, variables)
    Mustache.render(template, variables)
  end
end

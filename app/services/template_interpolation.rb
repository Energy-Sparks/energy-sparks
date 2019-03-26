require 'mustache'
require 'ostruct'

class TemplateInterpolation
  def initialize(object, with_objects: {})
    @object = object
    @with_objects = with_objects
  end

  def interpolate(*fields, with: {})
    templated = fields.inject(@with_objects) do |collection, field|
      collection[field] = process(@object.send(field), with)
      collection
    end
    OpenStruct.new(templated)
  end

private

  def process(template, variables)
    Mustache.render(template, variables)
  end
end

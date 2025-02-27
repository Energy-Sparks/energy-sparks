class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include LocaleHelper

  attr_reader :id, :classes

  def initialize(id: nil, classes: '')
    @id = id
    @classes = class_names(classes)
    add_classes(self.class.name.underscore.dasherize.parameterize)
  end

  def add_classes(classes)
    @classes = class_names(@classes, classes)
  end
end

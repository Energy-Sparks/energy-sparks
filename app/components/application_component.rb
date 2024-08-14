class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include LocaleHelper

  attr_reader :id, :classes

  def initialize(id: nil, classes: '')
    @id = id
    @classes = classes
  end
end

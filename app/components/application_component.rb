class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include LocaleHelper

  attr_reader :id, :classes

  def initialize(id: nil, classes: '')
    @id = id
    @classes = token_list(classes)
  end
end

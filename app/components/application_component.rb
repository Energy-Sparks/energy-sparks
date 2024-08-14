class ApplicationComponent < ViewComponent::Base
  attr_reader :id, :classes

  def initialize(id: nil, classes: '')
    @id = id
    @classes = classes
  end
end

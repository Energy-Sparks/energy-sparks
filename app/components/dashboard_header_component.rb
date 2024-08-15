class DashboardHeaderComponent < ApplicationComponent
  attr_reader :school

  def initialize(school:, id: nil, classes: '')
    super(id: id, classes: classes)
    @school = school
  end
end

class DashboardHeaderComponent < ApplicationComponent
  attr_reader :school

  def initialize(school:, audience: :adult, id: nil, classes: '')
    super(id: id, classes: "#{classes} #{audience}")
    @school = school
    @audience = audience
  end
end

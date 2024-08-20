class DashboardLoginComponent < ApplicationComponent
  attr_reader :school

  def initialize(school:, user: nil, id: nil, classes: '')
    super(id: id, classes: classes)
    @school = school
    @user = user
  end

  def render?
    @user.nil? || @user.guest?
  end
end

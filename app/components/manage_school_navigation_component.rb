class ManageSchoolNavigationComponent < ApplicationComponent
  attr_reader :school, :current_user

  def initialize(school:, current_user: nil, classes: '')
    super(id: 'page-nav', classes: classes)
    @school = school
    @current_user = current_user
  end

  def ability
    @ability ||= Ability.new(@current_user)
  end

  def can?(permission, context)
    ability.can?(permission, context)
  end
end

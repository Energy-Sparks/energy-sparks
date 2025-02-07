class AdminUserListComponent < ApplicationComponent
  attr_reader :users

  def initialize(id: nil, classes: '', users:, show_organisation: true)
    super(id: id, classes: classes)
    @users = users
    @show_organisation = show_organisation
  end

  def render?
    @users.any?
  end

  def show_organisation?
    @show_organisation
  end

  def row_class(user)
    if !user.active?
      'table-danger'
    elsif user.access_locked?
      'table-warning'
    else
      ''
    end
  end
end

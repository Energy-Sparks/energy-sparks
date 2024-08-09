class DashboardRemindersComponent < ApplicationComponent
  include ApplicationHelper

  delegate :can?, to: :helpers
  delegate :user_signed_in?, to: :helpers

  attr_reader :school, :user

  renders_one :title

  def initialize(school:, user:, heading: nil, id: nil, classes: '')
    super(id: id, classes: classes)
    @heading = heading
    @school = school
    @user = user
  end

  def add_prompt(list:, status:, icon:, check: true, id: nil, link: nil, path: nil)
    return unless check
    list.with_prompt id: id, status: status, icon: icon do |p|
      yield
      if link
        p.with_link { helpers.link_to I18n.t(link), path }
      end
    end
  end

  def show_data_enabled_features?
    if user && user.admin?
      # TODO
      true
      # params[:no_data] ? false : true
    else
      @school.data_enabled?
    end
  end

  def show_standard_prompts?
    return true if user && user.admin?
    return true if can?(:show_management_dash, @school)
    false
  end

  def can_manage_school?
    can?(:show_management_dash, @school)
  end

  def programmes_to_prompt
    @school.programmes.last_started
  end
end

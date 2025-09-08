class DashboardRemindersComponent < ApplicationComponent
  include ApplicationHelper

  attr_reader :school, :user
  renders_one :title

  def initialize(school:, user:, id: nil, classes: '')
    super(id: id, classes: classes)
    @school = school
    @user = user
  end

  def add_prompt(list:, status:, icon:, check: true, id: nil, link: nil, path: nil)
    return unless check
    list.with_prompt id: id, status: status, icon: icon do |p|
      yield
      p.with_link { helpers.link_to I18n.t(link), path } if link
    end
  end

  def show_data_enabled_features?
    if user && user.admin?
      true
    else
      @school.data_enabled?
    end
  end

  def programmes_to_prompt
    @school.programmes.active.last_started
  end

  private

  def ability
    @ability ||= Ability.new(@user)
  end

  def can?(permission, context)
    ability.can?(permission, context)
  end

  def site_settings
    @site_settings ||= SiteSettings.current
  end
end

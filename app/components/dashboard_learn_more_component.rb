# frozen_string_literal: true

class DashboardLearnMoreComponent < ApplicationComponent
  attr_reader :school, :user

  def initialize(school:, user:, id: nil, classes: '')
    @user = user
    @school = school
    super(id: id, classes: "#{classes} #{data_enabled_class}")
  end

  def data_enabled?
    return true if user.present? && user.admin? && @school.process_data?
    @school.data_enabled?
  end

  def data_enabled_class
    data_enabled? ? 'data-enabled' : 'data-disabled'
  end

  def title
    data_enabled? ? I18n.t('schools.dashboards.learn_more.title') : I18n.t('schools.show.coming_soon')
  end

  def intro
    data_enabled? ? I18n.t('schools.dashboards.learn_more.intro') : I18n.t('schools.show.configuring_data_access')
  end
end

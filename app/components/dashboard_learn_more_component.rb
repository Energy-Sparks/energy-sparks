# frozen_string_literal: true

class DashboardLearnMoreComponent < ApplicationComponent
  attr_reader :school, :user, :audience

  def initialize(school:, user:, audience: :adult, id: nil, classes: '')
    @user = user
    @school = school
    @audience = audience
    super(id: id, classes: "#{classes} #{data_enabled_class} #{audience}")
  end

  def data_enabled?
    return true if user.present? && user.admin? && @school.process_data?
    @school.data_enabled?
  end

  def adult?
    @audience == :adult
  end

  def data_enabled_class
    data_enabled? ? 'data-enabled' : 'data-disabled'
  end

  def title
    data_enabled? ? I18n.t("components.dashboard_learn_more.#{audience}.title") : I18n.t('schools.show.coming_soon')
  end

  def intro
    data_enabled? ? I18n.t("components.dashboard_learn_more.#{audience}.intro") : I18n.t('schools.show.configuring_data_access')
  end
end

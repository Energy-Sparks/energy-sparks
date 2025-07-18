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
    user&.admin? && @school.process_data? || @school.data_enabled?
  end

  def adult?
    @audience == :adult
  end

  def data_enabled_class
    data_enabled? ? 'data-enabled' : 'data-disabled'
  end

  def title
    if !data_enabled?
      I18n.t('schools.show.coming_soon')
    elsif @school.has_solar_pv? && audience == :adult
      I18n.t('components.dashboard_learn_more.adult.title_with_solar_pv')
    else
      I18n.t("components.dashboard_learn_more.#{audience}.title")
    end
  end

  def intro
    if data_enabled?
      I18n.t("components.dashboard_learn_more.#{audience}.intro")
    elsif adult?
      I18n.t('schools.show.configuring_data_access')
    else
      I18n.t('pupils.schools.show.setting_up')
    end
  end
end

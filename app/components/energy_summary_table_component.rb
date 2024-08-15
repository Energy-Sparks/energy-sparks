class EnergySummaryTableComponent < ApplicationComponent
  include ApplicationHelper
  include HelpPageHelper

  attr_reader :school, :user

  renders_one :footer

  def initialize(school:, show_savings: true, show_title: true, id: 'energy-summary', classes: '', user: nil)
    super(id: id, classes: classes)
    @user = user
    @school = school
    @show_savings = show_savings
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def show_savings?
    @show_savings
  end

  def overview_data
    @overview_data ||= Schools::ManagementTableService.new(@school).management_data
  end

  def row_for_last_week?(data)
    data.period_key == :workweek
  end

  def render?
    return false unless overview_data.present?
    @user&.admin? || @school.data_enabled?
  end

  def col(size = 1)
    "col-#{size}" if Flipper.enabled?(:new_dashboards_2024, user)
  end

  def no_data_message_class(data)
    return data.message_class unless Flipper.enabled?(:new_dashboards_2024, user)
    data.message_class == 'old-data' ? data.message_class : 'future-data'
  end

  def footer_link
    if Flipper.enabled?(:new_dashboards_2024, user)
      I18n.t('advice_pages.how_have_we_analysed_your_data.link_title')
    else
      "#{I18n.t('schools.show.more_information')} #{fa_icon('info-circle')}".html_safe
    end
  end

  def footer_classes
    Flipper.enabled?(:new_dashboards_2024, user) ? 'table-caption' : 'text-right management-overview-caption'
  end
end

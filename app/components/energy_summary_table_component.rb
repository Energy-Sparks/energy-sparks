class EnergySummaryTableComponent < ApplicationComponent
  include ApplicationHelper
  include HelpPageHelper

  attr_reader :school, :user

  renders_one :footer

  def initialize(school:, show_savings: true, show_title: true, id: nil, classes: '', user: nil)
    id = id || 'management-overview-table'
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
    return overview_data.present? if @user&.admin?
    @school.data_enabled?
  end
end

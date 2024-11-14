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

  # Bootstrap classes to allow th/td classes to be hidden on smallest mobile views
  def hidden_on_mobile
    'd-none d-sm-table-cell'
  end

  def col(size = 1)
    "col-#{size}"
  end

  def no_data_message_class(data)
    data.message_class == 'old-data' ? data.message_class : 'future-data'
  end
end

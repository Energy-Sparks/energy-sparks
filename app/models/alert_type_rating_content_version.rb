# == Schema Information
#
# Table name: alert_type_rating_content_versions
#
#  alert_type_rating_id                  :bigint(8)        not null
#  colour                                :integer          default("negative"), not null
#  created_at                            :datetime         not null
#  email_end_date                        :date
#  email_start_date                      :date
#  email_title                           :string
#  email_weighting                       :decimal(, )      default(5.0)
#  find_out_more_chart_title             :string           default("")
#  find_out_more_chart_variable          :text             default("none")
#  find_out_more_end_date                :date
#  find_out_more_start_date              :date
#  find_out_more_table_variable          :text             default("none")
#  find_out_more_title                   :string
#  find_out_more_weighting               :decimal(, )      default(5.0)
#  group_dashboard_alert_end_date        :date
#  group_dashboard_alert_start_date      :date
#  group_dashboard_alert_weighting       :decimal(, )      default(5.0)
#  id                                    :bigint(8)        not null, primary key
#  management_dashboard_alert_end_date   :date
#  management_dashboard_alert_start_date :date
#  management_dashboard_alert_weighting  :decimal(, )      default(5.0)
#  management_dashboard_table_end_date   :date
#  management_dashboard_table_start_date :date
#  management_dashboard_table_weighting  :decimal(, )      default(5.0)
#  management_priorities_end_date        :date
#  management_priorities_start_date      :date
#  management_priorities_weighting       :decimal(, )      default(5.0)
#  pupil_dashboard_alert_end_date        :date
#  pupil_dashboard_alert_start_date      :date
#  pupil_dashboard_alert_weighting       :decimal(, )      default(5.0)
#  replaced_by_id                        :integer
#  sms_content                           :string
#  sms_end_date                          :date
#  sms_start_date                        :date
#  sms_weighting                         :decimal(, )      default(5.0)
#  updated_at                            :datetime         not null
#
# Indexes
#
#  fom_content_v_fom_id  (alert_type_rating_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_rating_id => alert_type_ratings.id) ON DELETE => cascade
#

class AlertTypeRatingContentVersion < ApplicationRecord
  extend Mobility
  include TransifexSerialisable

  belongs_to :alert_type_rating
  belongs_to :replaced_by, class_name: 'AlertTypeRatingContentVersion', optional: true

  enum :colour, { negative: 0, neutral: 1, positive: 2 }

  translates :pupil_dashboard_title, backend: :action_text
  translates :management_dashboard_title, backend: :action_text
  translates :management_priorities_title, backend: :action_text
  translates :group_dashboard_title, backend: :action_text

  translates :email_title, type: :string, fallbacks: { cy: :en }
  translates :email_content, backend: :action_text
  translates :sms_content, type: :string, fallbacks: { cy: :en }

  has_rich_text :find_out_more_content

  TX_ATTRIBUTE_MAPPING = {
    pupil_dashboard_title: { templated: true },
    management_dashboard_title: { templated: true },
    management_priorities_title: { templated: true },
    group_dashboard_title: { templated: true },
    email_content: { templated: true },
    email_title: { templated: true },
    sms_content: { templated: true }
  }.freeze

  def self.functionality
    %i[
      pupil_dashboard_alert
      management_dashboard_alert
      management_priorities
      sms
      email
      group_dashboard_alert
    ]
  end

  def self.template_fields
    %i[
      pupil_dashboard_title
      management_dashboard_title
      email_title email_content sms_content
      management_priorities_title
      group_dashboard_title
    ]
  end

  def resource_key
    "#{self.class.model_name.i18n_key}_#{alert_type_rating.id}"
  end

  def tx_name
    "#{alert_type_rating.alert_type.title} - #{alert_type_rating.description}"
  end

  def tx_categories
    ['alert_rating']
  end

  def tx_valid_attribute(attr)
    case attr.to_sym
    when :pupil_dashboard_title
      alert_type_rating.pupil_dashboard_alert_active?
    when :management_dashboard_title
      alert_type_rating.management_dashboard_alert_active?
    when :management_priorities_title
      alert_type_rating.management_priorities_active?
    when :email_title
      alert_type_rating.email_active?
    when :email_content
      alert_type_rating.email_active?
    when :sms_content
      alert_type_rating.sms_active?
    when :group_dashboard_title
      alert_type_rating.group_dashboard_alert_active?
    end
  end

  def self.tx_resources
    AlertTypeRating.with_dashboard_email_sms_alerts.map(&:current_content)
  end

  def self.timing_fields
    functionality.map { |function| [:"#{function}_start_date", :"#{function}_end_date"] }.flatten
  end

  def self.weighting_fields
    functionality.map { |function| :"#{function}_weighting" }
  end

  validates :colour, presence: true

  validates :pupil_dashboard_title,
            presence: true,
            if: ->(content) { content.alert_type_rating && content.alert_type_rating.pupil_dashboard_alert_active? },
            on: :create
  validates :sms_content,
            presence: true,
            if: ->(content) { content.alert_type_rating && content.alert_type_rating.sms_active? },
            on: :create
  validates :email_title, :email_content,
            presence: true,
            if: ->(content) { content.alert_type_rating && content.alert_type_rating.email_active? },
            on: :create
  validates :management_dashboard_title,
            presence: true,
            if: lambda { |content|
              content.alert_type_rating && content.alert_type_rating.management_dashboard_alert_active?
            },
            on: :create
  validates :management_priorities_title,
            presence: true,
            if: ->(content) { content.alert_type_rating && content.alert_type_rating.management_priorities_active? },
            on: :create
  validates :group_dashboard_title,
            presence: true,
            if: ->(content) { content.alert_type_rating && content.alert_type_rating.group_dashboard_alert_active? },
            on: :create

  functionality.each do |function|
    validates :"#{function}_weighting",
              numericality: { greater_than_or_equal_to: 0 },
              if: lambda { |content|
                content.alert_type_rating && content.alert_type_rating.read_attribute(:"#{function}_active")
              }
  end

  validate on: :create do |content|
    if content.alert_type_rating
      self.class.functionality.each do |function|
        content.timings_are_correct(function) if content.alert_type_rating.read_attribute(:"#{function}_active")
      end
    end
  end

  scope :latest, -> { where(replaced_by_id: nil) }

  def meets_timings?(scope:, today:)
    start_date, end_date = start_end_end_date(scope)
    meets_start_date = start_date ? start_date <= today : true
    meets_end_date = end_date ? end_date >= today : true
    meets_start_date && meets_end_date
  end

  def timings_are_correct(scope)
    start_date, end_date = start_end_end_date(scope)
    return unless start_date.present? && end_date.present?
    return unless end_date < start_date

    errors.add(:"#{scope}_end_date", 'must be on or after start date')
  end

  private

  def start_end_end_date(scope)
    start_date_field = :"#{scope}_start_date"
    end_date_field = :"#{scope}_end_date"
    [self[start_date_field], self[end_date_field]]
  end
end

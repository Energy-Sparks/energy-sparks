# == Schema Information
#
# Table name: alert_type_rating_content_versions
#
#  alert_type_rating_id         :bigint(8)        not null
#  colour                       :integer          default("red"), not null
#  created_at                   :datetime         not null
#  email_content                :text
#  email_title                  :string
#  find_out_more_chart_title    :string           default("")
#  find_out_more_chart_variable :text             default("none")
#  find_out_more_content        :text
#  find_out_more_title          :string
#  id                           :bigint(8)        not null, primary key
#  pupil_dashboard_title        :string
#  replaced_by_id               :integer
#  sms_content                  :string
#  teacher_dashboard_title      :string
#  updated_at                   :datetime         not null
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
  belongs_to :alert_type_rating
  belongs_to :replaced_by, class_name: 'AlertTypeRatingContentVersion', foreign_key: :replaced_by_id

  enum colour: [:red, :yellow, :green]

  validates :colour, presence: true
  validates :teacher_dashboard_title,
    presence: true,
    if: ->(content) { content.alert_type_rating && content.alert_type_rating.teacher_dashboard_alert_active?},
    on: :create
  validates :pupil_dashboard_title,
    presence: true,
    if: ->(content) { content.alert_type_rating && content.alert_type_rating.pupil_dashboard_alert_active?},
    on: :create
  validates :find_out_more_title, :find_out_more_content,
    presence: true,
    if: ->(content) { content.alert_type_rating && content.alert_type_rating.find_out_more_active?},
    on: :create
  validates :sms_content,
    presence: true,
    if: ->(content) { content.alert_type_rating && content.alert_type_rating.sms_active?},
    on: :create
  validates :email_title, :email_content,
    presence: true,
    if: ->(content) { content.alert_type_rating && content.alert_type_rating.email_active?},
    on: :create

  scope :latest, -> { where(replaced_by_id: nil) }

  def self.template_fields
    [
      :pupil_dashboard_title, :teacher_dashboard_title,
      :find_out_more_title, :find_out_more_content,
      :email_title, :email_content, :sms_content,
      :find_out_more_chart_variable, :find_out_more_chart_title
    ]
  end
end

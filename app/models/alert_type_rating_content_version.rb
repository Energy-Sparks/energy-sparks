# == Schema Information
#
# Table name: alert_type_rating_content_versions
#
#  alert_type_rating_id    :bigint(8)        not null
#  colour                  :integer          default("red"), not null
#  created_at              :datetime         not null
#  email_active            :boolean          default(FALSE)
#  email_content           :text
#  email_title             :string
#  find_out_more_active    :boolean          default(FALSE)
#  id                      :bigint(8)        not null, primary key
#  page_content            :text             not null
#  page_title              :string           not null
#  pupil_dashboard_title   :string           not null
#  replaced_by_id          :integer
#  sms_active              :boolean          default(FALSE)
#  sms_content             :string
#  teacher_dashboard_title :string           not null
#  updated_at              :datetime         not null
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

  validates :teacher_dashboard_title, :pupil_dashboard_title, :page_title, :page_content, :colour, presence: true

  scope :latest, -> { where(replaced_by_id: nil) }

  def interpolated(field, variables)
    TemplateInterpolation.new(send(field)).interpolate(variables)
  end
end

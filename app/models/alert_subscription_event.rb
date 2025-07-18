# == Schema Information
#
# Table name: alert_subscription_events
#
#  alert_id                             :bigint(8)        not null
#  alert_type_rating_content_version_id :bigint(8)        not null
#  communication_type                   :integer          default("email"), not null
#  contact_id                           :bigint(8)        not null
#  created_at                           :datetime         not null
#  email_id                             :bigint(8)
#  find_out_more_id                     :bigint(8)
#  id                                   :bigint(8)        not null, primary key
#  message                              :text
#  priority                             :decimal(, )      default(0.0), not null
#  status                               :integer          default("pending"), not null
#  subscription_generation_run_id       :bigint(8)        not null
#  unsubscription_uuid                  :string
#  updated_at                           :datetime         not null
#
# Indexes
#
#  alert_sub_content_v_id                               (alert_type_rating_content_version_id)
#  ase_sgr_index                                        (subscription_generation_run_id)
#  index_alert_subscription_events_on_alert_id          (alert_id)
#  index_alert_subscription_events_on_contact_id        (contact_id)
#  index_alert_subscription_events_on_email_id          (email_id)
#  index_alert_subscription_events_on_find_out_more_id  (find_out_more_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_id => alerts.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_rating_content_version_id => alert_type_rating_content_versions.id) ON DELETE => cascade
#  fk_rails_...  (contact_id => contacts.id) ON DELETE => cascade
#  fk_rails_...  (email_id => emails.id) ON DELETE => nullify
#  fk_rails_...  (find_out_more_id => find_out_mores.id) ON DELETE => nullify
#  fk_rails_...  (subscription_generation_run_id => subscription_generation_runs.id) ON DELETE => cascade
#

class AlertSubscriptionEvent < ApplicationRecord
  belongs_to :contact, inverse_of: :alert_subscription_events
  belongs_to :alert
  belongs_to :email, optional: true
  has_one    :sms_record
  belongs_to :find_out_more, optional: true
  belongs_to :content_version, class_name: 'AlertTypeRatingContentVersion',
                               foreign_key: :alert_type_rating_content_version_id
  belongs_to :subscription_generation_run

  enum :status, { pending: 0, sent: 1, archived: 2 }
  enum :communication_type, { email: 0, sms: 1 }

  validates :priority, numericality: true

  scope :by_priority, -> { order(priority: :desc) }

  def sent_at
    email.sent_at if email
  end

  def sms_content
    TemplateInterpolation.new(
      content_version
    ).interpolate(
      :sms_content,
      with: alert.template_variables
    ).sms_content
  end
end

# == Schema Information
#
# Table name: alert_type_ratings
#
#  alert_type_id                     :bigint(8)        not null
#  created_at                        :datetime         not null
#  description                       :string           not null
#  email_active                      :boolean          default(FALSE)
#  find_out_more_active              :boolean          default(FALSE)
#  group_dashboard_alert_active      :boolean          default(FALSE)
#  id                                :bigint(8)        not null, primary key
#  management_dashboard_alert_active :boolean          default(FALSE)
#  management_dashboard_table_active :boolean          default(FALSE)
#  management_priorities_active      :boolean          default(FALSE)
#  public_dashboard_alert_active     :boolean          default(FALSE)
#  pupil_dashboard_alert_active      :boolean          default(FALSE)
#  rating_from                       :decimal(, )      not null
#  rating_to                         :decimal(, )      not null
#  sms_active                        :boolean          default(FALSE)
#  updated_at                        :datetime         not null
#
# Indexes
#
#  index_alert_type_ratings_on_alert_type_id  (alert_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_id => alert_types.id) ON DELETE => cascade
#

class AlertTypeRating < ApplicationRecord
  belongs_to :alert_type
  has_many :content_versions, class_name: 'AlertTypeRatingContentVersion'
  has_many :alert_type_rating_activity_types
  has_many :activity_types, through: :alert_type_rating_activity_types

  has_many :alert_type_rating_intervention_types
  has_many :intervention_types, through: :alert_type_rating_intervention_types

  scope :for_rating, ->(rating) { where('rating_from <= ? AND rating_to >= ?', rating, rating) }
  scope :pupil_dashboard_alert, -> { where(pupil_dashboard_alert_active: true) }
  scope :management_dashboard_alert, -> { where(management_dashboard_alert_active: true) }
  scope :management_priorities_title, -> { where(management_priorities_active: true) }
  scope :group_dashboard_alert, -> { where(group_dashboard_alert_active: true) }
  scope :email_active, -> { where(email_active: true) }
  scope :sms_active, -> { where(sms_active: true) }

  scope :with_dashboard_email_sms_alerts, -> { pupil_dashboard_alert.or(management_dashboard_alert).or(management_priorities_title).or(email_active).or(sms_active).or(group_dashboard_alert) }

  validates :rating_from, :rating_to, :description, presence: true
  validates :rating_from, :rating_to, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  validate :ratings_not_out_of_order

  accepts_nested_attributes_for :alert_type_rating_activity_types, reject_if: proc {|attributes| attributes['position'].blank? }
  accepts_nested_attributes_for :alert_type_rating_intervention_types, reject_if: proc {|attributes| attributes['position'].blank? }

  def current_content
    content_versions.latest.first
  end

  def update_with_content!(attributes, content)
    to_replace = current_content
    self.attributes = attributes
    if valid? && content.valid?
      save_and_replace(content, to_replace)
      true
    else
      false
    end
  end

  def update_activity_type_positions!(position_attributes)
    transaction do
      alert_type_rating_activity_types.destroy_all
      update!(alert_type_rating_activity_types_attributes: position_attributes)
    end
  end

  def update_intervention_type_positions!(position_attributes)
    transaction do
      alert_type_rating_intervention_types.destroy_all
      update!(alert_type_rating_intervention_types_attributes: position_attributes)
    end
  end

  def ordered_activity_types
    activity_types.order('alert_type_rating_activity_types.position').group('activity_types.id, alert_type_rating_activity_types.position')
  end

  def ordered_intervention_types
    intervention_types.order('alert_type_rating_intervention_types.position').group('intervention_types.id, alert_type_rating_intervention_types.position')
  end

  def priority_action_modal_text?
    I18n.t('school_groups.priority_actions.alert_types').key?("#{alert_type_class_key}_html".to_sym)
  end

  def priority_action_modal_text
    I18n.t("school_groups.priority_actions.alert_types.#{alert_type_class_key}_html")
  end

private

  def alert_type_class_key
    alert_type.class_name.underscore
  end

  def save_and_replace(content, to_replace)
    transaction do
      save!
      content.save!
      to_replace.update!(replaced_by: content) if to_replace
    end
  end

  def ratings_not_out_of_order
    if rating_from.present? && rating_to.present?
      if rating_to <= rating_from
        errors.add(:rating_to, 'must be less than rating from')
      end
    end
  end
end

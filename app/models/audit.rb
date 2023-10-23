# == Schema Information
#
# Table name: audits
#
#  completed_on    :date
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  involved_pupils :boolean          default(FALSE), not null
#  published       :boolean          default(TRUE)
#  school_id       :bigint(8)        not null
#  title           :string           not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_audits_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class Audit < ApplicationRecord
  belongs_to :school, inverse_of: :audits
  has_one_attached :file
  has_rich_text :description

  has_many :observations, dependent: :destroy

  validates_presence_of :school, :title, :file

  has_many :audit_activity_types
  has_many :activity_types, through: :audit_activity_types
  scope :with_activity_types, -> { where('id IN (SELECT DISTINCT(audit_id) FROM audit_activity_types)') }

  accepts_nested_attributes_for :audit_activity_types, allow_destroy: true

  has_many :audit_intervention_types
  has_many :intervention_types, through: :audit_intervention_types
  accepts_nested_attributes_for :audit_intervention_types, allow_destroy: true

  scope :published, -> { where(published: true) }
  scope :by_date,   -> { order(created_at: :desc) }

  def completed_activity_types
    activity_types.where(id: school.activities.where(happened_on: created_at..).pluck(:activity_type_id))
  end

  def completed_intervention_types
    intervention_types.where(id: school.observations.intervention.where(at: created_at..).pluck(:intervention_type_id))
  end

  def activities_completed?
    activity_type_ids = activity_types.pluck(:id)
    return if activity_type_ids.empty?
    # Checks if the associated school has completed all activites that corresponds with the activity types
    # listed in the audit.  It only includes activities logged after the audit was created and completed within
    # 12 months of the audit's creation date.
    (activity_type_ids - school.activities.where('happened_on >= :start_date AND happened_on <= :end_date', start_date: created_at, end_date: created_at + 12.months).pluck(:activity_type_id)).empty?
  end

  def create_activities_completed_observation!
    return unless SiteSettings.current.audit_activities_bonus_points
    return unless activities_completed?
    return if observations&.audit_activities_completed.present? # Only one audit activities completed observation is permitted per audit

    Observation.create!(
      school: school,
      observation_type: :audit_activities_completed,
      audit: self,
      at: Time.zone.now,
      points: SiteSettings.current.audit_activities_bonus_points
    )
  end
end

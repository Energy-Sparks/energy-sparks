# == Schema Information
#
# Table name: observations
#
#  _description         :text
#  activity_id          :bigint(8)
#  at                   :datetime         not null
#  audit_id             :bigint(8)
#  created_at           :datetime         not null
#  id                   :bigint(8)        not null, primary key
#  intervention_type_id :bigint(8)
#  involved_pupils      :boolean          default(FALSE), not null
#  observation_type     :integer          not null
#  points               :integer
#  school_id            :bigint(8)        not null
#  school_target_id     :bigint(8)
#  updated_at           :datetime         not null
#  visible              :boolean          default(TRUE)
#
# Indexes
#
#  index_observations_on_activity_id           (activity_id)
#  index_observations_on_audit_id              (audit_id)
#  index_observations_on_intervention_type_id  (intervention_type_id)
#  index_observations_on_school_id             (school_id)
#  index_observations_on_school_target_id      (school_target_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_id => activities.id) ON DELETE => nullify
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (intervention_type_id => intervention_types.id) ON DELETE => restrict
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (school_target_id => school_targets.id)
#

class Observation < ApplicationRecord
  belongs_to :school
  has_many   :temperature_recordings
  has_many   :locations, through: :temperature_recordings
  belongs_to :intervention_type, optional: true
  belongs_to :activity, optional: true
  belongs_to :audit, optional: true
  belongs_to :school_target, optional: true
  enum observation_type: [:temperature, :intervention, :activity, :event, :audit, :school_target]

  validates_presence_of :at, :school
  validates_associated :temperature_recordings

  validates :intervention_type_id, presence: { message: 'please select an option' }, if: :intervention?
  validates :activity_id, presence: true, if: :activity?
  validates :audit_id, presence: true, if: :audit?
  validates :school_target_id, presence: true, if: :school_target?

  validates :pupil_count, absence: true, unless: :intervention? # Only record pupil counts for interventions

  accepts_nested_attributes_for :temperature_recordings, reject_if: :reject_temperature_recordings

  scope :visible, -> { where(visible: true) }
  scope :by_date, -> { order(at: :desc) }
  scope :for_school, ->(school) { where(school: school) }
  scope :between, ->(first_date, last_date) { where('at BETWEEN ? AND ?', first_date, last_date) }
  scope :recorded_in_last_year, -> { where('created_at >= ?', 1.year.ago)}
  scope :recorded_in_last_week, -> { where('created_at >= ?', 1.week.ago)}

  has_rich_text :description

  before_save :add_points_for_interventions

  private

  def add_points_for_interventions
    if intervention?
      academic_year = school.academic_year_for(at)
      if academic_year&.current? && involved_pupils?
        self.points = intervention_type.score
      end
    end
  end

  def reject_temperature_recordings(attributes)
    attributes['centigrade'].blank?
  end
end

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
#  programme_id         :bigint(8)
#  pupil_count          :integer
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
#  index_observations_on_programme_id          (programme_id)
#  index_observations_on_school_id             (school_id)
#  index_observations_on_school_target_id      (school_target_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_id => activities.id) ON DELETE => nullify
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (intervention_type_id => intervention_types.id) ON DELETE => restrict
#  fk_rails_...  (programme_id => programmes.id) ON DELETE => cascade
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

  # If adding a new observation type remember to also add a timelime template in app/views/schools/observations/timeline
  # event: 3 was removed as its no longer used
  enum observation_type: { temperature: 0, intervention: 1, activity: 2, audit: 4, school_target: 5, programme: 6, audit_activities_completed: 7, observable: 8 }

  # This is the first stage in moving this class over to being fully polymorphic
  # The idea is to eventually move all observation_types (above) to this way of doing things
  belongs_to :observable, polymorphic: true, optional: true

  validates_presence_of :at, :school
  validates_associated :temperature_recordings

  validates :intervention_type_id, presence: { message: 'please select an option' }, if: :intervention?
  validates :activity_id, presence: true, if: :activity?
  validates :audit_id, presence: true, if: :audit?
  validates :school_target_id, presence: true, if: :school_target?
  validates :audit_id, presence: true, if: :audit_activities_completed?

  validates :pupil_count, absence: true, unless: :intervention? # Only record pupil counts for interventions

  accepts_nested_attributes_for :temperature_recordings, reject_if: :reject_temperature_recordings

  scope :visible, -> { where(visible: true) }
  scope :by_date, -> { order(at: :desc) }
  scope :for_school, ->(school) { where(school: school) }
  scope :between, ->(first_date, last_date) { where('at BETWEEN ? AND ?', first_date, last_date) }
  scope :recorded_in_last_year, -> { where('created_at >= ?', 1.year.ago)}
  scope :recorded_in_last_week, -> { where('created_at >= ?', 1.week.ago)}
  scope :recorded_since, ->(date) { where('created_at >= ?', date)}

  scope :engagement, -> { where(observation_type: [:temperature, :intervention, :activity, :audit, :school_target, :programme]) }

  has_rich_text :description

  before_save :add_points_for_interventions, if: :intervention?
  before_save :add_bonus_points_for_included_images, if: proc { |observation| observation.activity? || observation.intervention? }

  before_validation :set_observable, if: :observable

  def self.default_timeline_icon
    'square-check'
  end

  private

  def add_bonus_points_for_included_images
    # Only add bonus points if the site wide photo bonus points is set to non zero
    return unless SiteSettings.current.photo_bonus_points&.nonzero?
    # Only add bonus points if the current observation score is non zero
    return unless self.points&.nonzero?
    # Only add bonus points if the description has an image
    return unless description_includes_images?

    self.points = (self.points || 0) + SiteSettings.current.photo_bonus_points
  end

  def description_includes_images?
    if intervention?
      description&.body&.to_trix_html&.include?("figure")
    elsif activity?
      description&.body&.to_trix_html&.include?("figure") || activity.description_includes_images?
    end
  end

  def add_points_for_interventions
    record_points_for_current_academic_year
  end

  def record_points_for_current_academic_year
    return unless school.academic_year_for(at)&.current?

    self.points = intervention_type.score
  end

  def reject_temperature_recordings(attributes)
    attributes['centigrade'].blank?
  end

  def set_observable
    self.observation_type = :observable

    # Take the school from the related object
    self.school = self.observable.school if self.observable.school
  end
end

# == Schema Information
#
# Table name: observations
#
#  _description         :text
#  activity_id          :bigint(8)
#  at                   :datetime         not null
#  audit_id             :bigint(8)
#  created_at           :datetime         not null
#  created_by_id        :bigint(8)
#  id                   :bigint(8)        not null, primary key
#  intervention_type_id :bigint(8)
#  involved_pupils      :boolean          default(FALSE), not null
#  observable_id        :bigint(8)
#  observable_type      :string
#  observation_type     :integer          not null
#  points               :integer
#  programme_id         :bigint(8)
#  pupil_count          :integer
#  school_id            :bigint(8)        not null
#  school_target_id     :bigint(8)
#  updated_at           :datetime         not null
#  updated_by_id        :bigint(8)
#  visible              :boolean          default(TRUE)
#
# Indexes
#
#  index_observations_on_activity_id                        (activity_id)
#  index_observations_on_audit_id                           (audit_id)
#  index_observations_on_created_by_id                      (created_by_id)
#  index_observations_on_intervention_type_id               (intervention_type_id)
#  index_observations_on_observable_type_and_observable_id  (observable_type,observable_id)
#  index_observations_on_programme_id                       (programme_id)
#  index_observations_on_school_id                          (school_id)
#  index_observations_on_school_target_id                   (school_target_id)
#  index_observations_on_updated_by_id                      (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_id => activities.id) ON DELETE => nullify
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (intervention_type_id => intervention_types.id) ON DELETE => restrict
#  fk_rails_...  (programme_id => programmes.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (school_target_id => school_targets.id)
#  fk_rails_...  (updated_by_id => users.id)
#

class Observation < ApplicationRecord
  include Description
  include Todos::Recording

  belongs_to :school

  has_many   :temperature_recordings
  has_many   :locations, through: :temperature_recordings

  belongs_to :programme, optional: true # to be removed when column is removed
  belongs_to :intervention_type, optional: true
  belongs_to :activity, optional: true
  belongs_to :audit, optional: true # to be removed when column is removed
  belongs_to :school_target, optional: true # to be removed when column is removed
  belongs_to :created_by, optional: true, class_name: 'User'
  belongs_to :updated_by, optional: true, class_name: 'User'

  # When adding a new observation type, use the polymorphic `observable` relationship
  # instead of adding a new foreign key / relationship. The goal is to transition existing relationships
  # (e.g., programme, audit, school_target) to `observable` over time.
  # Prioritize using the new model when working in these areas, as they are the easiest to migrate.
  # If adding a new observation type, remember to also modify the timeline component

  # NB: events: 3 has been removed
  enum :observation_type, { temperature: 0, intervention: 1, activity: 2, audit: 4, school_target: 5, programme: 6,
                            audit_activities_completed: 7, transport_survey: 8 }

  belongs_to :observable, polymorphic: true, optional: true

  validates :at, :school, presence: true
  validates_associated :temperature_recordings

  validates :intervention_type_id, presence: { message: 'please select an option' }, if: :intervention?
  validates :activity_id, presence: true, if: :activity?
  validates :observable_id, presence: true, unless: -> { temperature? || intervention? || activity? }
  validates :pupil_count, absence: true, unless: :intervention? # Only record pupil counts for interventions

  accepts_nested_attributes_for :temperature_recordings, reject_if: :reject_temperature_recordings

  scope :with_points, -> { where('points IS NOT NULL AND points > 0') }
  scope :visible, -> { where(visible: true) }
  scope :by_date, ->(order = :desc) { order(at: order) }
  scope :for_school, ->(school) { where(school: school) }
  scope :between, ->(first_date, last_date) { where(at: first_date..last_date) }
  scope :in_academic_year, ->(academic_year) { between(academic_year.start_date, academic_year.end_date) }
  scope :in_academic_year_for, lambda { |school, date|
    (academic_year = school.academic_year_for(date)) ? in_academic_year(academic_year) : none
  }
  scope :recorded_in_last_year, -> { where('created_at >= ?', 1.year.ago) }
  scope :recorded_in_last_week, -> { where('created_at >= ?', 1.week.ago) }
  scope :recorded_since, ->(range) { where(created_at: range) }
  scope :not_including, ->(school) { where.not(school:).recorded_since(school.current_academic_year.start_date..) }
  scope :for_visible_schools, -> { joins(:school).merge(School.visible) }
  scope :engagement, lambda {
    where(observation_type: %i[temperature intervention activity audit school_target programme transport_survey])
  }

  scope :with_academic_year, -> {
    joins('JOIN academic_years ON observations.at BETWEEN academic_years.start_date AND academic_years.end_date')
  }

  scope :counts_by_academic_year, -> {
    with_academic_year.group('academic_years.id').count
  }

  has_rich_text :description

  before_validation :set_defaults, if: -> { observable_id }, on: :create
  before_save :add_points_for_activities, if: :activity?
  before_save :add_points_for_interventions, if: :intervention?

  before_save :add_bonus_points_for_included_images, if: proc { |observation|
    observation.activity? || observation.intervention?
  }

  def description_includes_images?
    if intervention?
      super
    elsif activity?
      super || activity.description_includes_images?
    end
  end

  def happened_on
    at.to_date
  end

  private

  def add_points_for_activities
    self.points = activity.activity_type.score_when_recorded_at(school, at)
  end

  def add_points_for_interventions
    self.points = intervention_type.score_when_recorded_at(school, at)
  end

  def add_bonus_points_for_included_images
    # Only add bonus points if the site wide photo bonus points is set to non zero
    return unless SiteSettings.current.photo_bonus_points&.nonzero?
    # Only add bonus points if the current observation score is non zero
    return unless points&.nonzero?
    # Only add bonus points if the description has an image
    return unless description_includes_images?

    self.points = (points || 0) + SiteSettings.current.photo_bonus_points
  end

  def reject_temperature_recordings(attributes)
    attributes['centigrade'].blank?
  end

  def set_defaults
    # set the observation type from the observable_type if not already set
    self.observation_type ||= observable_type.underscore.to_sym
    self.school ||= observable.school if observable.school
    self.at ||= Time.zone.now
  end
end

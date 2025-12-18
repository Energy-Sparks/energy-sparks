# == Schema Information
#
# Table name: programme_types
#
#  active            :boolean          default(FALSE)
#  bonus_score       :integer          default(0)
#  created_at        :datetime         default(Wed, 06 Jul 2022 12:00:00.000000000 UTC +00:00), not null
#  default           :boolean          default(FALSE)
#  document_link     :string
#  id                :bigint(8)        not null, primary key
#  short_description :text
#  title             :text
#  updated_at        :datetime         default(Wed, 06 Jul 2022 12:00:00.000000000 UTC +00:00), not null
#

class ProgrammeType < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  include TranslatableAttachment
  include Todos::Assignable

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :short_description, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text
  translates :document_link, type: :string, fallbacks: { cy: :en }

  t_has_one_attached :image

  ## these two relationships to be removed when todos feature removed
  # has_many :programme_type_activity_types
  # has_many :activity_types, through: :programme_type_activity_types

  has_many :programmes

  scope :active, -> { where(active: true) }
  scope :default, -> { where(default: true) }
  scope :by_title, -> { i18n.order(title: :asc) }

  scope :default_first, -> { order(default: :desc) }
  scope :featured, -> { active.default_first.by_title }
  scope :tx_resources, -> { active.order(:id) }

  scope :with_school_activity_type_task_count, ->(school) {
    joins("INNER JOIN todos on todos.assignable_id = programme_types.id and todos.assignable_type = 'ProgrammeType'")
    .joins("INNER JOIN activities on todos.task_id = activities.activity_type_id and todos.task_type = 'ActivityType'")
    .where(activity_types: { activities: { school: school } })
    .select('programme_types.*, count(distinct activities.activity_type_id) as recording_count')
    .group('programme_types.id').order(recording_count: :desc)
  }

  scope :with_school_intervention_type_task_count, ->(school) {
    joins("INNER JOIN todos on todos.assignable_id = programme_types.id and todos.assignable_type = 'ProgrammeType'")
    .joins("INNER JOIN observations on todos.task_id = observations.intervention_type_id and todos.task_type = 'InterventionType'")
    .where(observations: { school_id: school.id })
    .select('programme_types.*, count(distinct observations.intervention_type_id) as recording_count')
    .group('programme_types.id').order(recording_count: :desc)
  }

  scope :not_in, ->(programme_types) { where.not(id: programme_types) }

  validates_presence_of :title
  validates :bonus_score, numericality: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :default, if: :default

  def activity_types_by_position
    programme_type_activity_types.order(:position).map(&:activity_type)
  end

  def programme_for_school(school)
    programmes.where(school: school).last
  end

  def activity_of_type_for_school(school, activity_type)
    if (programme = programme_for_school(school))
      programme.activity_of_type(activity_type)
    end
  end

  def update_activity_type_positions!(position_attributes)
    transaction do
      programme_type_activity_types.destroy_all
      update!(programme_type_activity_types_attributes: position_attributes)
    end
  end

  def activity_types_and_school_activity(school)
    programme_type_activity_types.order(:position).map do |programme_type_activity_type|
      activity = school.activities.find_by(activity_type_id: programme_type_activity_type.activity_type_id)
      [programme_type_activity_type.activity_type, activity]
    end
  end

  def repeatable?(school)
    # Only allow a repeat if the school hasn't completed this programe type this academic year
    school.programmes.where(programme_type: self).completed.where(ended_on: school.current_academic_year.start_date..).none?
  end

  # Provide a list of activity types a school has already completed this year for this programme type
  # regardless of having signed up to the programme
  def activity_type_ids_for_school(school)
    activity_types.pluck(:id) & school.activity_types_in_academic_year.pluck(:id)
  end

  # Has the provided school already completed all activity types this year?
  # regardless of having signed up to the programme
  def all_activity_types_completed_for_school?(school)
    (activity_types.pluck(:id) - school.activity_types_in_academic_year.pluck(:id)).empty?
  end
end

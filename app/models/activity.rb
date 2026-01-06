# == Schema Information
#
# Table name: activities
#
#  activity_category_id :bigint(8)
#  activity_type_id     :bigint(8)        not null
#  created_at           :datetime         not null
#  created_by_id        :bigint(8)
#  happened_on          :date
#  id                   :bigint(8)        not null, primary key
#  pupil_count          :integer
#  school_id            :bigint(8)        not null
#  title                :string
#  updated_at           :datetime         not null
#  updated_by_id        :bigint(8)
#
# Indexes
#
#  index_activities_on_activity_category_id  (activity_category_id)
#  index_activities_on_activity_type_id      (activity_type_id)
#  index_activities_on_created_by_id         (created_by_id)
#  index_activities_on_school_id             (school_id)
#  index_activities_on_updated_by_id         (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_category_id => activity_categories.id) ON DELETE => restrict
#  fk_rails_...  (activity_type_id => activity_types.id) ON DELETE => restrict
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (updated_by_id => users.id)
#

class Activity < ApplicationRecord
  include Description
  include Todos::Recording

  belongs_to :school, inverse_of: :activities
  belongs_to :activity_type, inverse_of: :activities
  belongs_to :activity_category, optional: true
  belongs_to :created_by, optional: true, class_name: 'User'
  belongs_to :updated_by, optional: true, class_name: 'User'

  has_many :programme_activities
  has_many :programmes, through: :programme_activities

  # Probably should be a has_one relationship
  # At last check, activities had one obsevation each (with four having none)
  has_many :observations

  validates_presence_of :school, :activity_type, :activity_category, :happened_on

  scope :for_activity_type, ->(activity_type) { where(activity_type: activity_type) }
  scope :for_school, ->(school) { where(school: school) }
  scope :most_recent, -> { order(created_at: :desc) }
  scope :by_date, ->(order = :asc) { order(happened_on: order) }
  scope :between, ->(first_date, last_date) { where('activities.happened_on BETWEEN ? AND ?', first_date, last_date) }
  scope :in_academic_year, ->(academic_year) { between(academic_year.start_date, academic_year.end_date) }

  # If no academic year is found for school for specified date, nothing is returned
  scope :in_academic_year_for, ->(school, date) { (academic_year = school.academic_year_for(date)) ? in_academic_year(academic_year) : none }
  scope :recorded_in_last_year, -> { where('created_at >= ?', 1.year.ago)}
  scope :recorded_in_last_week, -> { where('created_at >= ?', 1.week.ago)}

  has_rich_text :description

  after_update :update_observations

  self.ignored_columns = %w(deprecated_description)

  def display_name
    activity_type.custom ? title : activity_type.name
  end

  # There should only ever be one observation per activity
  # But we maintain has_many relationship for now
  def points
    observations.sum(:points)
  end

  def academic_year
    school.academic_year_for(happened_on)
  end

  private

  def description_previously_changed?
    rich_text_description&.previous_changes&.key?('body')
  end

  def update_observations?
    happened_on_previously_changed? || description_previously_changed? || updated_by_previously_changed?
  end

  def update_observations
    if update_observations?
      observations.each { |o| o.update(updated_by:, at: happened_on) } # forces callbacks to update points
    end
  end
end

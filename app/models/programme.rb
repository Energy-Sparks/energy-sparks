# == Schema Information
#
# Table name: programmes
#
#  created_at        :datetime         not null
#  ended_on          :date
#  id                :bigint(8)        not null, primary key
#  programme_type_id :bigint(8)        not null
#  school_id         :bigint(8)        not null
#  started_on        :date             not null
#  status            :integer          default("started"), not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_programmes_on_programme_type_id  (programme_type_id)
#  index_programmes_on_school_id          (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (programme_type_id => programme_types.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class Programme < ApplicationRecord
  belongs_to :programme_type
  belongs_to :school
  has_many :programme_activities
  has_many :activities, through: :programme_activities
  has_many :observations, as: :observable, dependent: :destroy

  enum status: { started: 0, completed: 1, abandoned: 2 } do
    event :complete do
      after do
        self.update(ended_on: Time.zone.now)
        self.add_observation
      end
      transition :started => :completed
    end

    event :abandon do
      transition :started => :abandoned
    end
  end

  scope :recently_started, ->(date) { where('created_at > ?', date) }
  scope :recently_started_non_default, ->(date) { recently_started(date).where.not(programme_type: ProgrammeType.default) }
  scope :in_reverse_start_order, -> { started.order(started_on: :desc) }
  scope :active, -> { joins(:programme_type).merge(ProgrammeType.active) }
  scope :last_started, -> { in_reverse_start_order.limit(1) }
  scope :recently_ended, ->(date: 1.day.ago) { where('ended_on >= ?', date) }
  delegate :title, :description, :short_description, :document_link, :image, :bonus_score, to: :programme_type

  def points_for_completion
    # Only apply the bonus points if the programme is completed in the same academic year
    school.academic_year_for(started_on)&.current? ? programme_type.bonus_score : 0
  end

  def activity_types_completed
    activities.map(&:activity_type).uniq
  end

  def activity_of_type(activity_type)
    activities.where(activity_type: activity_type).last
  end

  def add_observation
    return unless completed?

    self.observations.programme.first_or_create(at: self.ended_on, points: points_for_completion)
  end
end

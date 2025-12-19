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
  include Todos::Completable

  belongs_to :programme_type
  belongs_to :school

  # has_many :programme_activities # remove this when :todos feature flag removed
  # has_many :activities, through: :programme_activities # remove this when :todos feature flag removed

  has_many :observations, as: :observable, dependent: :destroy

  enum :status, { started: 0, completed: 1, abandoned: 2 } do
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

  scope :recently_started, ->(date_range) { where(created_at: date_range) }
  scope :recently_started_non_default,
        ->(date_range) { recently_started(date_range).where.not(programme_type: ProgrammeType.default) }
  scope :in_reverse_start_order, -> { order(started_on: :desc) }
  scope :active, -> { joins(:programme_type).merge(ProgrammeType.active) }
  scope :last_started, -> { started.in_reverse_start_order.limit(1) }
  scope :recently_ended, ->(date: 1.day.ago) { where('ended_on >= ?', date) }
  delegate :title, :description, :short_description, :document_link, :image, to: :programme_type

  scope :completable, -> { started.active }

  def assignable
    programme_type
  end

  def points_for_completion
    programme_type.bonus_score
  end

  def add_observation
    return unless completed?

    self.observations.programme.first_or_create(at: self.ended_on, points: points_for_completion)
  end
end

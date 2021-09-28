# == Schema Information
#
# Table name: programmes
#
#  ended_on          :date
#  id                :bigint(8)        not null, primary key
#  programme_type_id :bigint(8)        not null
#  school_id         :bigint(8)        not null
#  started_on        :date             not null
#  status            :integer          default("started"), not null
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

  enum status: { started: 0, completed: 1, abandoned: 2 } do
    event :complete do
      after do
        self.update(ended_on: Time.zone.now)
      end
      transition :started => :completed
    end

    event :abandon do
      transition :started => :abandoned
    end
  end

  scope :active, -> { joins(:programme_type).merge(ProgrammeType.active) }

  delegate :title, :description, :short_description, :document_link, :image, to: :programme_type

  def activity_types_completed
    activities.map(&:activity_type).uniq
  end

  def activity_of_type(activity_type)
    activities.where(activity_type: activity_type).last
  end
end

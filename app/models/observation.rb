# == Schema Information
#
# Table name: observations
#
#  _description         :text
#  activity_id          :bigint(8)
#  at                   :datetime         not null
#  created_at           :datetime         not null
#  id                   :bigint(8)        not null, primary key
#  intervention_type_id :bigint(8)
#  observation_type     :integer          not null
#  points               :integer
#  school_id            :bigint(8)        not null
#  updated_at           :datetime         not null
#  visible              :boolean          default(TRUE)
#
# Indexes
#
#  index_observations_on_activity_id           (activity_id)
#  index_observations_on_intervention_type_id  (intervention_type_id)
#  index_observations_on_school_id             (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_id => activities.id) ON DELETE => nullify
#  fk_rails_...  (intervention_type_id => intervention_types.id) ON DELETE => restrict
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class Observation < ApplicationRecord
  belongs_to :school
  has_many   :temperature_recordings
  has_many   :locations, through: :temperature_recordings
  belongs_to :intervention_type, optional: true
  belongs_to :activity, optional: true

  enum observation_type: [:temperature, :intervention, :activity, :event]

  validates_presence_of :at, :school
  validate :at_date_cannot_be_in_the_future
  validates_associated :temperature_recordings

  validates :intervention_type_id, presence: { message: 'please select an option' }, if: :intervention?
  validates :activity_id, presence: true, if: :activity?

  accepts_nested_attributes_for :temperature_recordings, reject_if: :reject_temperature_recordings

  scope :visible, -> { where(visible: true) }
  scope :by_date, -> { order(at: :desc) }
  scope :for_school, ->(school) { where(school: school) }

  has_rich_text :description

  def at_date_cannot_be_in_the_future
    errors.add(:at, "can't be in the future") if at.present? && at > Time.zone.today.end_of_day
  end

private

  def reject_temperature_recordings(attributes)
    attributes['centigrade'].blank?
  end
end

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
  include Todos::Assignable
  include Todos::Completable

  belongs_to :school, inverse_of: :audits
  has_one_attached :file
  has_rich_text :description

  has_many :observations, as: :observable, dependent: :destroy

  validates_presence_of :school, :title, :file

  scope :published, -> { where(published: true) }
  scope :by_date,   -> { order(created_at: :desc) }
  scope :completable, -> { published }

  def assignable
    self
  end

  def available_bonus_points
    completed? ? 0 : SiteSettings.current.audit_activities_bonus_points
  end

  def completed?
    observations.audit_activities_completed.any?
  end

  def tasks_completed_on
    observations.audit_activities_completed.last.at
  end

  def complete!
    # I think we should raise here too if the site has no bonus points set
    return unless SiteSettings.current.audit_activities_bonus_points
    # There is no flag on audit to say all tasks are completed, apart from observation being present
    # So halt here if observation is present
    return if completed?
    # Are there todos and are they complete?
    return unless completable?

    self.observations.audit_activities_completed.create!(points: SiteSettings.current.audit_activities_bonus_points)
  end
end

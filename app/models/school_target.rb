class SchoolTarget < ApplicationRecord
  belongs_to :school

  validates_presence_of :school, :target
  validate :must_have_one_target

  scope :by_date, -> { order(created_at: :desc) }

  def current?
    Time.zone.now <= target
  end

  private

  def must_have_one_target
    if electricity.blank? && gas.blank? && storage_heaters.blank?
      errors.add :base, "At least one target must be provided"
    end
  end
end

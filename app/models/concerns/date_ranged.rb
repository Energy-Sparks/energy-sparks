module DateRanged
  extend ActiveSupport::Concern

  included do
    validate :validate_date_range
  end

  private

  def validate_date_range
    return unless start_date && end_date && (end_date < start_date)
    errors.add(:end_date, 'must be on or after the start date')
  end
end

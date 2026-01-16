module TemporalRange
  extend ActiveSupport::Concern

  include DateRanged

  included do
    scope :historical, ->(today = Time.zone.today) {
      where('end_date < ?', today)
    }

    scope :current, ->(today = Time.zone.today) {
      where('start_date <= ? AND end_date >= ?', today, today)
    }

    scope :future, ->(today = Time.zone.today) {
      where('start_date > ?', today)
    }
  end

  def current?(today = Time.zone.today)
    start_date <= today && end_date >= today
  end

  def historical?(today = Time.zone.today)
    end_date < today
  end

  def future?(today = Time.zone.today)
    start_date > today
  end
end

module TemporalRange
  extend ActiveSupport::Concern

  include DateRanged

  included do
    scope :historical, ->(today = Time.zone.today) {
      where("#{table_name}.end_date < ?", today)
    }

    scope :current, ->(today = Time.zone.today) {
      where("#{table_name}.start_date <= ? AND #{table_name}.end_date >= ?", today, today)
    }

    scope :future, ->(today = Time.zone.today) {
      where("#{table_name}.start_date > ?", today)
    }

    scope :expiring, ->(end_date = (Time.zone.today + 1.month).end_of_month) {
      where("#{table_name}.end_date <= ?", end_date)
    }

    scope :recently_expired, ->(end_date = (Time.zone.today - 1.month).beginning_of_month) {
      where("#{table_name}.end_date <= ?", end_date)
    }

    scope :recent, ->(updated_at = (Time.zone.today - 1.month).beginning_of_month) {
      where("#{table_name}.created_at >= ?", updated_at)
    }

    scope :recently_updated, ->(updated_at = (Time.zone.today - 1.month).beginning_of_month) {
      where("#{table_name}.updated_at >= ? AND #{table_name}.updated_at > #{table_name}.created_at", updated_at)
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

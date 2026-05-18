module TemporalRange
  extend ActiveSupport::Concern

  include DateRanged

  included do
    scope :current, lambda { |today = Time.zone.today|
      where("#{table_name}.start_date <= ? AND #{table_name}.end_date >= ?", today, today)
    }

    scope :future, lambda { |today = Time.zone.today|
      where("#{table_name}.start_date > ?", today)
    }

    scope :expiring, lambda { |end_date = (Time.zone.today + 1.month).end_of_month|
      where("#{table_name}.end_date >= CURRENT_DATE and #{table_name}.end_date <= ?", end_date)
    }

    scope :expired, lambda { |today = Time.zone.today|
      where("#{table_name}.end_date < ?", today)
    }

    scope :recently_expired, lambda { |end_date = (Time.zone.today - 1.month).beginning_of_month|
      where("#{table_name}.end_date >= ? and #{table_name}.end_date < ?", end_date, Time.zone.today)
    }

    scope :recent, lambda { |created_at = (Time.zone.today - 1.month).beginning_of_month|
      where("#{table_name}.created_at >= ?", created_at)
    }

    scope :recently_updated, lambda { |updated_at = (Time.zone.today - 1.month).beginning_of_month|
      where("#{table_name}.updated_at >= ? AND #{table_name}.updated_at > #{table_name}.created_at", updated_at)
    }
  end

  def current?(today = Time.zone.today)
    start_date <= today && end_date >= today
  end

  def expired?(today = Time.zone.today)
    end_date < today
  end

  def future?(today = Time.zone.today)
    start_date > today
  end
end

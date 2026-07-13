module TemporalRange
  extend ActiveSupport::Concern

  include DateRanged

  # rubocop:disable Metrics/BlockLength
  included do
    scope :current, lambda { |today = Time.zone.today|
      where("#{table_name}.start_date <= ? AND #{table_name}.end_date >= ?", today, today)
    }

    scope :future, ->(today = Time.zone.today) { where("#{table_name}.start_date > ?", today) }

    scope :current_and_future, ->(today = Time.zone.today) { where("#{table_name}.end_date >= ?", today) }

    scope :expiring, lambda { |end_date = (Time.zone.today + 1.month).end_of_month|
      where("#{table_name}.end_date >= CURRENT_DATE and #{table_name}.end_date <= ?", end_date)
    }

    scope :expired, ->(today = Time.zone.today) { where("#{table_name}.end_date < ?", today) }

    scope :recently_expired, lambda { |end_date = (Time.zone.today - 1.month).beginning_of_month|
      where("#{table_name}.end_date >= ? and #{table_name}.end_date < ?", end_date, Time.zone.today)
    }

    scope :recent, lambda { |created_at = (Time.zone.today - 1.month).beginning_of_month|
      where("#{table_name}.created_at >= ?", created_at)
    }

    scope :recently_updated, lambda { |updated_at = (Time.zone.today - 1.month).beginning_of_month|
      where("#{table_name}.updated_at >= ? AND #{table_name}.updated_at > #{table_name}.created_at", updated_at)
    }

    scope :for_period, lambda { |period|
      where(
        'start_date <= ? AND end_date >= ?',
        period.end,
        period.begin
      ).by_start_date
    }

    # Define in model, returning array of attributes
    def temporal_group_keys
      raise NotImplementedError
    end

    scope :overlapping, lambda {
      group_conditions = temporal_group_keys.map { |key| "t2.#{key} = #{table_name}.#{key}" }.join(' AND ')

      joins(<<~SQL.squish)
        INNER JOIN #{table_name} AS t2
          ON #{group_conditions}
         AND t2.id <> #{table_name}.id
         AND t2.start_date <= #{table_name}.end_date
         AND t2.end_date >= #{table_name}.start_date
      SQL
        .distinct
    }
  end
  # rubocop:enable Metrics/BlockLength

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

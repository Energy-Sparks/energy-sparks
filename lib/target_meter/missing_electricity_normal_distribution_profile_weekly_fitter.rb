# frozen_string_literal: true

#
# given up to 52 weeks of data fit a seasonal profile
# to the weekly electricity data
# general documentation for approach under:
# Google Drive\Energy Sparks\Energy Sparks Project Team Documents\Analytics\Targeting and Tracking\Targeting and Tracking Modelling Analysis.gdoc
#
class TargetMeter
  class MissingElectricityNormalDistributionProfileWeeklyFitter
    MAXWEEKSANALYSIS = 53 # to cover just over a year as 52.14 weeks in a year
    MINDAYSINWEEKFORANALYSIS = 3
    class TooMuchData < StandardError; end

    def initialize(amr_data, holidays, start_date, end_date)
      if end_date - start_date > MAXWEEKSANALYSIS * 7
        raise TooMuchData,
              "Only up to 1 year expected but got #{start_date} to #{end_date}"
      end

      @amr_data = amr_data
      @holidays = holidays
      @start_date = start_date
      @end_date = end_date
    end

    def self.week_of_year(date)
      jan_1 = Date.new(date.year, 1, 1)
      sunday_of_week1 = jan_1 - jan_1.wday
      week = ((date - sunday_of_week1) / 7).to_i
    end

    # returns a normalised fit of 52 or 53 weeks of estimated/fitted electricity
    # profile data for a school between start, end dates; summ of kWhs = 1.0
    def fit(exclude_date_ranges: [])
      school_weeks_kwh = aggregate_schoolweek_kwhs(@start_date, @end_date, exclude_date_ranges)
      return nil if school_weeks_kwh.empty?

      sd, _eps = fit_optimum_sd(school_weeks_kwh)
      synthetic_profile = SyntheticSeasonalSchoolWeeklyElectricityProfile.new(sd, school_weeks_kwh,
                                                                              self.class.week_of_year(@start_date), self.class.week_of_year(@end_date))
      profile = synthetic_profile.profile
      { profile: profile, actual: school_weeks_kwh, sd: sd }
    end

    private

    def aggregate_schoolweek_kwhs(start_date, end_date, exclude_date_ranges)
      return {} if @amr_data.start_date > start_date || @amr_data.end_date < end_date

      school_week_kwh       = Array.new(MAXWEEKSANALYSIS, 0.0)
      school_week_day_count = Array.new(MAXWEEKSANALYSIS, 0.0)

      (start_date..end_date).each do |date|
        next if @holidays.day_type(date) != :schoolday

        next if in_date_ranges?(exclude_date_ranges, date)

        week = MissingElectricityNormalDistributionProfileWeeklyFitter.week_of_year(date)

        school_week_kwh[week]       += @amr_data.one_day_kwh(date)
        school_week_day_count[week] += 1.0
      end

      average_school_day_kwh_by_week = school_week_kwh.map.with_index do |kwh, week|
        if school_week_day_count[week] >= MINDAYSINWEEKFORANALYSIS
          kwh / school_week_day_count[week]
        else
          Float::NAN
        end
      end

      total = average_school_day_kwh_by_week.map { |v| v.nan? ? 0.0 : v }.sum

      school_day_kwh_by_week_normalised_to_1 = average_school_day_kwh_by_week.map { |kwh| kwh / total }
    end

    def in_date_ranges?(date_ranges, date)
      return false if date_ranges.nil? || date_ranges.empty?

      date_ranges.each do |date_range|
        return true if date.between?(date_range.first, date_range.last)
      end
      false
    end

    def fit_optimum_sd(school_weeks_kwh)
      optimum = Minimiser.minimize(10.0, 50.0) { |sd| difference_to_theoretical_profile(sd, school_weeks_kwh) }
      [optimum.x_minimum, optimum.f_minimum]
    end

    def difference_to_theoretical_profile(sd, school_weeks_kwh)
      theoretical_profile = SyntheticSeasonalSchoolWeeklyElectricityProfile.new(sd.to_f, school_weeks_kwh,
                                                                                MissingElectricityNormalDistributionProfileWeeklyFitter.week_of_year(@start_date),
                                                                                MissingElectricityNormalDistributionProfileWeeklyFitter.week_of_year(@end_date)).profile
      difference(school_weeks_kwh, theoretical_profile)
    end

    def difference(school_profile, standard_profile)
      diff = 0.0
      school_profile.each_with_index do |val, index|
        diff += (val - standard_profile[index]).magnitude unless val.nan?
      end
      diff
    end

    class SyntheticSeasonalSchoolWeeklyElectricityProfile
      attr_reader :profile

      def initialize(sd, weekly_kwhs, start_week, end_week)
        weeks_avg_kwh = map_to_weeks(NormalDistributionProfile.new(sd).profile, start_week, end_week)
        @profile = weeks_avg_kwh.map { |v| v * 52.0 / school_weeks(weekly_kwhs) }
      end

      private

      # norm profile produces a profile staring at the lowest in July, peaking
      # in December then low again for June
      # so remap to the start/end dates of the year defined by the actual data
      def map_to_weeks(profile, start_week, end_week)
        centre_week = start_week - 3 # lowest consumption approx week 23 not mid year at week 26, for fitting purposes
        profile[centre_week..51] + profile[0...centre_week] + profile[centre_week..centre_week]
      end

      def school_weeks(weekly_kwhs)
        weekly_kwhs.count { |wkwh| !wkwh.nan? }
      end
    end

    class NormalDistributionProfile
      def initialize(sd, mean = 26, n = 52)
        @sd = sd
        @n = n
        @mean = mean
      end

      def profile
        dist = (0...@n).to_a.map { |x| normal_distribution(@sd, @mean, x) }
        sum = dist.sum
        normalised_to_1 = dist.map { |v| v / sum }
      end

      private

      def normal_distribution(sd, mean, x)
        (1.0 / (sd * ((2.0 * Math::PI)**0.5))) * Math.exp(-0.5 * (((x - mean) / sd)**2.0))
      end
    end
  end
end

# frozen_string_literal: true

# for targeting and tracking:
# - where there is less than 1 year of gas amr_data
# - and the gas modelling is working
# estimate a complete year's worth of gas data using regression model data
class TargetMeter
  class MissingGasModelEstimation < MissingGasEstimationBase
    class NoDefaultProfileForMissingModel < StandardError; end
    HEATING_ON_DEGREE_DAYS = 0.0

    def complete_year_amr_data
      missing_days = calculate_missing_days

      scale = if @annual_kwh.nil?
                1.0
              else
                missing_days_scale(missing_days)
              end

      scale_description = scale == 1.0 ? ' - no annual kwh estimate to scale' : ''

      add_scaled_missing_days(missing_days, scale)

      model_description = heating_model.models.transform_values(&:to_s)

      results = {
        amr_data: one_year_amr_data,
        feedback: {
          percent_real_data: (365 - missing_days.length) / 365.0,
          adjustments_applied: "less than 1 years data, filling in missing using regression models #{scale_description}",
          rule: self.class.name,
          unadjusted_missing_days_kwh: @total_missing_days,
          total_real_kwh: @total_kwh_so_far,
          annual_estimated_kwh: @annual_kwh,
          percent_synthetic_kwh: (@annual_kwh - @total_kwh_so_far) / @annual_kwh
        }
      }

      results[:feedback].merge!(model_description)
      results[:feedback].merge!(@feedback) unless @feedback.nil?

      results
    end

    private

    def calculate_missing_days
      missing_days = {}

      @target_dates.missing_date_range.each do |date|
        next if one_year_amr_data.date_exists?(date)

        avg_temp = @meter.meter_collection.temperatures.average_temperature(date)

        dd = @meter.meter_collection.temperatures.degree_days(date)

        heating_on = dd > HEATING_ON_DEGREE_DAYS

        days_kwh = if heating_on
                     heating_model.predicted_heating_kwh_future_date(date, avg_temp)
                   else
                     heating_model.predicted_non_heating_kwh_future_date(date, avg_temp)
                   end

        model_type = heating_on ? full_heating_model.heating_model_for_future_date(date) : heating_model.non_heating_model_for_future_date(date)

        missing_days[date] = { days_kwh: days_kwh, profile: profile_by_model_type(model_type) }
      end
      missing_days
    end

    def missing_days_scale(missing_days)
      @total_kwh_so_far = calculate_holey_amr_data_total_kwh(one_year_amr_data)

      @total_missing_days = # statsample bug avoidance
        missing_days.values.map do |missing_day|
          missing_day[:days_kwh]
        end.sum
      remaining_kwh = @annual_kwh - @total_kwh_so_far

      remaining_kwh / @total_missing_days
    end

    def add_scaled_missing_days(missing_days, scale)
      missing_days.each do |date, missing_day|
        add_scaled_days_kwh(date, scale * missing_day[:days_kwh], missing_day[:profile])
      end
    end

    def profile_by_model_type(model_type)
      # ideally just pickup the profile from the benchmark period i.e. before the target is set
      # but in the event the bacnhamrk period, only for example contains winter heating data,
      # or summer hot water data, then be more fault tolerant and use all available profile name
      # TODO(PH, 20Aug2021) - consider whether day of week specific profile might be more appropriate?
      profiles_by_model_type_x48[:benchmark][model_type] || profiles_by_model_type_x48[:all][model_type] || missing_profile(model_type)
    end

    def profiles_by_model_type_x48
      @profiles_by_model_type_x48 ||= calculate_profiles_by_model_type_x48
    end

    def calculate_profiles_by_model_type_x48
      {
        benchmark: calculate_profiles_by_model_type_x48_by_date_range(@target_dates.benchmark_date_range,
                                                                      heating_model),
        all: calculate_profiles_by_model_type_x48_by_date_range(@target_dates.original_meter_date_range,
                                                                full_heating_model)
      }
    end

    def missing_profile(model_type)
      case model_type
      when :unknown
        profile_by_model_type(:heating_occupied_all_days) || profile_by_model_type(:heating_occupied_wednesday)
      when :weekend_heating
        profile_by_model_type(:weekend_hotwater_only)
      else
        # TODO(PH, 12Aug2021, and ongoing) need to come up with default profiles,
        #                                   either artificially or from other model results
        #                                   as per the above example, which doesn't work
        raise NoDefaultProfileForMissingModel, "Missing model type #{model_type}"
      end
    end

    def calculate_profiles_by_model_type_x48_by_date_range(date_range, model)
      profiles_by_model_type = {}

      date_range.each do |date|
        if one_year_amr_data.date_exists?(date)
          model_type = model.model_type?(date)

          profiles_by_model_type[model_type] ||= []

          profiles_by_model_type[model_type].push(@amr_data.days_kwh_x48(date))
        else
          error = "Missing gas amr data: #{date.strftime('%a %d %b %Y')} #{@meter.fuel_type} #{@meter.mpxn}"
          @feedback ||= {}
          @feedback[:missing_gas_estimation_amr_data] ||= []
          @feedback[:missing_gas_estimation_amr_data].push(error)
        end
      end

      profiles_by_model_type.transform_values do |n_x_48|
        total_all_days_x48 = AMRData.fast_add_multiple_x48_x_x48(n_x_48)
        AMRData.fast_multiply_x48_x_scalar(total_all_days_x48, 1.0 / total_all_days_x48.sum)
      end
    end
  end
end

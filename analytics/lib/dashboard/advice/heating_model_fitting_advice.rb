require 'erb'

# extension of DashboardEnergyAdvice for heating regression model fitting
class DashboardEnergyAdvice

  def self.heating_model_advice_factory(chart_type, school, chart_definition, chart_data, chart_symbol)
    case chart_type
    when :group_by_week_gas_model_fitting_one_year #expert analysis
      ModelFittingIntroductionAndOneYearWeeklyGas.new(school, chart_definition, chart_data, chart_symbol)
    when :group_by_week_gas_model_fitting_unlimited #expert analysis
      ModelFittingOneWeekUnlimitedGas.new(school, chart_definition, chart_data, chart_symbol)
    when :gas_by_day_of_week_model_fitting #expert analysis
      ModelFittingGasByDayOfWeek.new(school, chart_definition, chart_data, chart_symbol)
    when :gas_longterm_trend_model_fitting #expert analysis
      ModelFittingAnnualGasConsumptionTrends.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_regression_simple_school_day_non_heating_regression_covid_tolerant #expert analysis
      HeatingNonHeatingSeparationIntroAndCovidModel.new(school, chart_definition, chart_data, chart_symbol)
    when :seasonal_simple_school_day_non_heating_regression_covid_tolerant #expert analysis
      SeasonalHeatingNonHeatingSeparationCovidModel.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_regression_simple_school_day_non_heating_regression #expert analysis
      HeatingNonHeatingSeparationRegressionModel.new(school, chart_definition, chart_data, chart_symbol)
    when :seasonal_simple_school_day_non_heating_regression #expert analysis
      SeasonalHeatingNonHeatingSeparationRegressionModel.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_regression_simple_school_day_non_heating_non_regression #expert analysis
      HeatingNonHeatingSeparationNonRegressionModel.new(school, chart_definition, chart_data, chart_symbol)
    when :seasonal_simple_school_day_non_heating_non_regression #expert analysis
      SeasonalHeatingNonHeatingSeparationNonRegressionModel.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_regression_simple_school_day #expert analysis
      ModelFittingIntroductionAndCategorisation.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_regression_simple_all #expert analysis
      ModelFittingSimpleAllCategorisations.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_regression_thermally_massive_school_day #expert analysis
      ModelFittingThermallMassiveModelSchoolDay.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_regression_thermally_massive_all #expert analysis
      ModelFittingThermallMassiveModelAllCategorisations.new(school, chart_definition, chart_data, chart_symbol)
    when :cusum_weekly_best_model #expert analysis
      ModelFittingModellingDecision.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_winter_holiday_best #expert analysis
      ModelFittingWinterHolidayHeating.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_winter_weekend_best #expert analysis
      ModelFittingWinterWeekendHeating.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_summer_school_day_holiday_best #expert analysis
      ModelFittingSummerSchoolDayAndHoliday.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_summer_weekend_best #expert analysis
      ModelFittingSummerWeekend.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_non_best #expert analysis
      ModelFittingMinimalDailyConsumption.new(school, chart_definition, chart_data, chart_symbol)
    when :cusum_simple #expert analysis
      ModelFittingCUSUMAnalysisSimpleModel.new(school, chart_definition, chart_data, chart_symbol)
    when :cusum_thermal_mass #expert analysis
      ModelFittingCUSUMAnalysisThermallMassiveModel.new(school, chart_definition, chart_data, chart_symbol)
    when :heating_on_off_by_week #expert analysis
      ModelFittingSplittingHeatingAndNonHeating.new(school, chart_definition, chart_data, chart_symbol)
    when :thermostatic_model_categories_pie_chart #expert analysis
      ModelFittingSplittingIntoCategoriesPieChart.new(school, chart_definition, chart_data, chart_symbol)
    else
      nil
    end
  end

  class ModelFittingAdviceBase < DashboardChartAdviceBase
    def initialize(chart_type, school, chart_definition, chart_data, advice_function = :heating_and_non_heating)
      super(chart_type, school, chart_definition, chart_data)
      set_heat_meter
      @advice_function = advice_function
    end

    def generate_advice
      if advice_valid?
        generate_valid_advice
      else
        header_template = %{
          <%= @body_start %>
            <p>
              <strong>This chart and advice are not relevent for this meter whose function is <%= meter_function_description %></strong>
            </p>
          <%= @body_end %>
        }.gsub(/^  /, '')

        @header_advice = generate_html(header_template, binding)

        @footer_advice = nil_advice
      end
    end

    protected

    # not ideal, would prefer if meter was part of constructor chain
    # but for bulk of advice the meter is not relevant, so extract from chart definition
    private def set_heat_meter
      meter_definition = @chart_definition[:meter_definition]
      if meter_definition == :allheat
        @heat_meter = @school.aggregated_heat_meters
      elsif meter_definition == :storage_heater_meter
        @heat_meter = @school.storage_heater_meter
      elsif meter_definition == :allelectricity
        raise EnergySparksUnexpectedStateException.new('Not expecting aggregate electricity meter for model fitting dashboard advice')
      else
        @heat_meter = @school.meter?(meter_definition)
        raise EnergySparksUnexpectedStateException.new("No meter for model fitting dashboard advice #{meter_definition}") if @heat_meter.nil?
        unless @heat_meter.heat_meter?
          raise EnergySparksUnexpectedStateException.new("Not expecting non heat meter for model fitting dashboard advice #{meter_definition}")
        end
      end
    end

    def meter_function_description
      @heat_meter.non_heating_only? ? 'non heating only' : (@heat_meter.heating_only? ? 'heating only' : 'heating and non heating')
    end



    def generate_valid_advice
      EnergySparksAbstractBaseClass.new('Call to heating model fitting advice base class not expected')
    end

    def advice_valid?
      case @advice_function
      when :heating_and_non_heating, :heating_only
        !@heat_meter.non_heating_only?
      when :non_heating_only
        @heat_meter.non_heating_only?
      else
        raise EnergySparksUnexpectedStateException.new("Unexpected advice status #{@advice_function}")
      end
    end

    def heating_model(model_type)
      @heating_model = @school.model_cache.create_and_fit_model(model_type, current_year)
    end

    def heat_amr;               heat_meter.amr_data end
    def heat_meter;             @heat_meter end

    def annual_gas_kwh_£
      kwh = heat_amr.kwh_period(current_year)
      annual_kwh = FormatUnit.format(:kwh, kwh)
      £ = ConvertKwh.convert(:kwh, :£, :gas, kwh)
      £_format = FormatUnit.format(:£, £).gsub(/£/, '&pound;')
      if days_gas_data > 360
        "#{annual_kwh} of gas in the last year at a cost of #{£_format}"
      else
        "#{annual_kwh} of gas in the last #{days_gas_data} days at a cost of #{£_format}"
      end
    end

    def days_gas_data
      heat_amr.end_date - heat_amr.start_date
    end

    def school_name;            @school.name end
    def floor_area;             @school.floor_area end
    def pupils;                 @school.number_of_pupils end

    def current_year(min_days = 200)
      end_date = heat_amr.end_date
      start_date = [end_date - 364, heat_amr.start_date].max
      days = end_date - start_date
      raise EnergySparksNotEnoughDataException.new("Not enough data to fit model and provide advice, only #{days} days") if days < min_days
      SchoolDatePeriod.new(:alert, 'Current Year', start_date, end_date)
    end

    def best_model
      heat_meter.heating_model(current_year, :best)
    end

    def overridden_model?
      best_model.name == 'Overridden'
    end

    def simple_model
      heat_meter.heating_model(current_year, :simple_regression_temperature)
    end

    def thermally_massive_model
      heat_meter.heating_model(current_year, :thermal_mass_regression_temperature)
    end

    def r2
      best_model.average_heating_school_day_r2
    end

    def r2_rating(r2)
      AnalyseHeatingAndHotWater::HeatingModel.r2_rating_adjective(r2)
    end

    def school_heating_days
      best_model.number_of_heating_school_days
    end

    def school_heating_day_adjective(days)
      AnalyseHeatingAndHotWater::HeatingModel.school_heating_day_adjective(days)
    end

    def average_school_heating_days
      AnalyseHeatingAndHotWater::HeatingModel.average_school_heating_days
    end

    def non_school_heating_days
      best_model.number_of_non_school_heating_days
    end

    def non_school_heating_day_adjective(days)
      AnalyseHeatingAndHotWater::HeatingModel.non_school_heating_day_adjective(days)
    end

    def average_non_school_heating_days
      AnalyseHeatingAndHotWater::HeatingModel.average_non_school_day_heating_days
    end

    def model_standard_devation_table_html
      header = ['Model', 'Standard Deviation kWh', 'Standard Deviation (%)', 'Average R2', 'Average base temperature', 'Calculation time(ms)']
      rows = []
      rows.push(formatted_model_deviation_information(simple_model))
      rows.push(formatted_model_deviation_information(thermally_massive_model))
      rows.push(formatted_model_deviation_information(best_model)) if overridden_model?
      html_table(header, rows)
    end

    def formatted_model_deviation_information(model)
      [
        model.name,
        FormatUnit.format(:kwh, model.standard_deviation),
        (model.standard_deviation_percent * 100.0).round(1).to_s + '%',
        model.average_heating_school_day_r2.round(2),
        model.average_base_temperature.round(1).to_s + 'C',
        (model.model_calculation_time * 1000.0).to_i
      ]
    end

    def regression_parameters_html_table(model)
      sorted_models = best_model.sorted_model_keys(model.models)

      header = ['Name', 'A kWh/day', 'B kWh/day/C', 'R2', 'Base Temperature(C)','Samples', 'Example prediction kWh/day']
      rows = []
      sorted_models.each do |name, results|
        rows.push(
          [
            name,
            round_nan(results.a, 0),
            round_nan(results.b, 0),
            round_nan(results.r2, 2),
            round_nan(results.base_temperature, 1),
            results.samples,
            example_predicted_kwh(model, name, results)
          ]
        )
      end
      html_table(header, rows)
    end

    def example_predicted_kwh(model, name, results)
      temperature = model.heating_model?(name) ? 8.0 : 20.0
      kwh = results.predicted_kwh_temperature(temperature)
      FormatUnit.format(:kwh, kwh) + "@ #{temperature.round(1)}C"
    end

    def round_nan(value, dp)
      value.nil? ? '' :  value.nan? ? 'NaN' : value.round(dp)
    end

    # copied from heating_regression_model_fitter.rb TODO(PH,17Feb2019) - merge
    def html_table(header, rows)
      template = %{
        <p>
          <table class="table table-striped table-sm">
            <thead>
              <tr class="thead-dark">
                <% header.each do |header_titles| %>
                  <th scope="col"> <%= header_titles.to_s %> </th>
                <% end %>
              </tr>
            </thead>
            <tbody>
              <% rows.each do |row| %>
                <tr>
                  <% row.each do |val| %>
                    <td> <%= val %> </td>
                  <% end %>
                </tr>
              <% end %>
            </tbody>
          </table>
        </p>
      }.gsub(/^  /, '')

      generate_html(template, binding)
    end
  end

  class ModelFittingIntroductionAndOneYearWeeklyGas < ModelFittingAdviceBase
    include Logging

    def non_tariff_meter_attributes
      heat_meter.all_attributes.select { |k, _v| !k.to_s.include?('tariff')}
    end

    # amazing print requires rails to do ap html
    # formatting, so do manually
    def non_tariff_attributes_html
      text = if Object.const_defined?('Rails')
                %{
                  <pre>
                    <%= non_tariff_meter_attributes.awesome_inspect({ html: true }) %>
                  </pre>
                }
              else
                %{
                  <pre>
                    <%= non_tariff_meter_attributes.pretty_inspect %>
                  </pre>
                }
              end

      ERB.new(text).result(binding)
    end

    def school_summary_html
      %{
        <h2>Summary: <%= @chart_definition[:meter_definition] %> <%= name %></h2>
        <p>
          In summary:
        </p>
        <ul>
          <li>
            <%= school_name %> has a floor area of <%= floor_area %> m2, and <%= pupils %> pupils.
            It uses <%= annual_gas_kwh_£%>.
          </li>
          <li>
            Thermostatic heating control is <%= r2_rating(r2) %> with an R2 of <%= r2.round(2) %>
            (1.0 being perfect, 0.0 being very poor)
          </li>
          <li>
              The school has its heating on for <%= school_heating_days %> school days each year,
              which is <%= school_heating_day_adjective(school_heating_days) %>,
              the average for schools is <%= average_school_heating_days %> days
          </li>
          <li>
              The school has its heating on for <%= non_school_heating_days %> non-school days each year,
              which is <%= non_school_heating_day_adjective(non_school_heating_days) %>,
              the average for schools is <%= average_non_school_heating_days %> days
          </li>
        </ul>
        <p>
            <strong>Meter Attributes</strong>
        </p>
        <% if non_tariff_meter_attributes.empty? %>
          <p>
            The meter has no 'attributes' set for this meter.
          </p>
        <% else %>
          <p>
            The meter has the following non-tariff attributes configured for it:
          </p>
          <p>
            <%= non_tariff_attributes_html %>
          </p>
        <% end %>
        <p>
          The remainder of this webpage explains the heating gas consumption
          modelling process, and present the calculation results.
        </p>
      }
    end

    def modelling_background_html
      %{
        <h3>Background</h3>
        <p>
            This is a statistical process which Energy Sparks uses to try to model the
            heating energy consumption of a school, using regression modelling
            techniques.
        </p>
        <p>
            During the winter, building gas consumption goes linearly as it gets
            colder. In a thermostatically well controlled building the daily heating
            gas consumption should be proportional to the difference between the inside
            and outside temperatures. So, if the building's internal temperature was
            20C, you would expect twice as much gas to be used on a day when it is 0C
            outside compared with a day when its 10C outside, as the temperature
            difference (20C = 20C - 0C) is double on the colder day (compared with 10C
            = 20C - 10C).
        </p>
        <p>
            The modelling is subsequently used for:
        </p>
        <p>
          <ul>
            <li>
                Adjusting/normalising gas consumption for outside temperature, so
                comparisons can be made between differing days
            </li>
            <li>
                Calculating missing data - the Smart Meter data fed to Energy Sparks
                often has gaps, which we need to fill in, by finding days with similar
                temperatures where the data isn't missing, and then using the model to
                calculate the theoretical gas consumption for the missing day using that
                day's temperature data
            </li>
            <li>
                Estimating the potential reduced gas consumption from reducing the
                school's internal temperature&#47;thermostat settings
            </li>
            <li>
                Providing feedback via alerts on the quality of the thermostatic
                control R2), number of days in the year the heating is on, significant
                (temperature compensated) changes in gas consumption
            </li>
          </ul>
        </p>
      }
    end

    def modelling_process_explanation_html
      %{
        <h3>Process</h3>
        <p>
            The process involves:
        </p>
        <ul>
          <li>
            Trying to identify periods when the heating is on or off:

            <ol type="a">
              <li>
                  Which starts by looking at the summer gas consumption when you would
                  assume gas is just being used for hot water and in the kitchen
              </li>
              <li>
                  Statistically modelling the distribution of this consumption
              </li>
              <li>
                  Inferring from this modelling when the heating is on (i.e. if the gas
                  consumption is significantly outside this distribution)
              </li>
            </ol>
          </li>
          <li>
            Then calculating the regression models:

            <ol type="1">
              <li>
                  Splitting the last year of daily consumption (kWh) into 7 categories -
                  school days, weekends, holidays times heating on, hot water and kitchen on
                  only, plus nothing on
              </li>
              <li>
                  Doing regression calculations on each of those categorised groups of
                  days, to calculate the linear relationship between outside temperature and
                  gas consumption
              </li>
              <li>
                  Repeating 2. Above, but with the school heating days split into
                  different days of the week; some buildings are thermally massive, and take
                  several days to heat up- so the gas consumption on a Monday (higher), is
                  different from that of a Friday (lower) for example
              </li>
              <li>
                  Statistically comparing the modelling produced in 2 and 3 with the real
                  daily consumption (CUSUM space), and determining which of 2 or 3 is the
                  best modelling to use for the advice provided by Energy Sparks
              </li>
            </ol>
          </li>
        </ul>
        <p>
            This calculation takes place every day, using the latest year's worth of
            gas smart meter data and temperature data, when Energy Sparks starts up.
        </p>
        <h2>
            What happens when the modelling doesn't work
        </h2>
        <p>
            In rare circumstances, after reviewing the charts below we might override
            the modelling results. This is generally in the circumstance where the data
            is too noisy for the statistical modelling to automatically work out what
            is going on with a school's gas consumption - typically if the school's
            consumption is dysfunctional.
        </p>
      }
    end

    def regression_modelling_1_html
      %{
        <h2>
            Regression Modelling
        </h2>
        <p>
            The remaining charts and information on this webpage take you through the
            modelling calculations for this school.
        </p>
        <h2>
            Overview of school's gas consumption
        </h2>
        <p>
            First of all, to put the analysis in context we look at an overview of the
            school's gas consumption, to understand approximately the school's gas
            usage patterns. These are charts which are also provided in the 'Analysis -
            Gas Detail' webpages on Energy Sparks, but repeated here to understand the
            context of the school's gas usage:
        </p>
        <h3>
            Weekly gas consumption versus how cold it is over the last year
        </h3>
      }
    end

    def generate_valid_advice
      meter = @school.meter?(@chart_definition[:meter_definition], true)
      name = meter.nil? || meter.name.empty? ? '' : "(#{meter.name})"
      html_components = [
        '<h1>Heating Regression Model Fitting</h1>',
         school_summary_html,
         modelling_background_html,
         modelling_process_explanation_html,
         regression_modelling_1_html
      ]

      @header_advice = generate_html_from_array_adding_body_tags(html_components, binding)

      footer_template = %{
          <%= @body_start %>
          <p>
            Generally the weekly gas consumption (bar chart) should follow the 'Degree
            Days' (how cold it is) line - with gas consumption increasing in the winter
            as it gets colder (high degree days). This chart is also useful for
            understanding:
          </p>
          <ol type="1">
            <li>
                By looking at the summer consumption, whether the school uses gas for
                heating and hot water (would expect the data to be zero if gas wasn't used
                for heating and hot water)
            </li>
            <li>
                Seeing whether the school turns boilers for hot water and heating off
                during the holidays
            </li>
            <li>
                Generally getting a feel for whether the gas consumption and the degree
                days track each other well - providing an indication of the quality of the
                school's thermostatic control
            </li>
          </ol>
          <%= @body_end %>
        }.gsub(/^  /, '')

        @footer_advice = generate_html(footer_template, binding)
    end
  end

  class ModelFittingOneWeekUnlimitedGas < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h3>
            Weekly gas consumption versus how cold it is over the period for which we
            have smart meter gas consumption data
          </h3>
            <p>
            This is a repeat of the previous chart, but over a longer time period, so
            it can be difficult to see the detail, but it helps in understanding
            whether there has been a change in usage patterns over the last few years.
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

        @header_advice = generate_html(header_template, binding)

        footer_template = %{
          <%= @body_start %>
          <%= @body_end %>
        }.gsub(/^  /, '')

        @footer_advice = generate_html(footer_template, binding)
    end
  end

  class ModelFittingGasByDayOfWeek < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h3>
            Heating by day of the week
          </h3>
          <p>
            This aggregates the heating usage by day of the week over the last year:
          </p
        <%= @body_end %>
      }.gsub(/^  /, '')

        @header_advice = generate_html(header_template, binding)

        footer_template = %{
          <%= @body_start %>
            <p>
                This provides a feel for whether the school building is 'thermally massive'
                - typically more gas consumption at the start of the week versus the end,
                as the building gradually heats up over the weekend. Whether the heating is
                on at weekends, and whether there are other anomalies in the daily
                consumption patterns.
            </p>
          <%= @body_end %>
        }.gsub(/^  /, '')

        @footer_advice = generate_html(footer_template, binding)
    end
  end

  class ModelFittingAnnualGasConsumptionTrends < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h3>
            Annual gas consumption over the last few years
          </h3>
          <p>
              This just summarises the annual gas consumption over the last few year's
              which might help uin spotting overall trends:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

        @header_advice = generate_html(header_template, binding)

        @footer_advice = nil_advice
    end
  end

  class HeatingNonHeatingSeparationAdviceBase < ModelFittingAdviceBase
    def model_type; nil end

    def model
      @model ||= @heat_meter.heating_model(period, :simple_regression_temperature_no_overrides, model_type)
    end

    def period
      end_date = @heat_meter.amr_data.end_date
      start_date = [end_date - 364, @heat_meter.amr_data.start_date].max
      period = SchoolDatePeriod.new(:optimisation, 'optmisation', start_date, end_date)
    end

    def model_results_html
      text = %{
        <h3>Results of model calculations:</h3>
        <%= HtmlTableFormatting.new(['Variable', 'Value'], model.non_heating_model.model_results.to_a).html %>
      }
      ERB.new(text).result(binding)
    end
  end

  class HeatingNonHeatingSeparationIntroAndCovidModel < HeatingNonHeatingSeparationAdviceBase
    def model_type; :temperature_sensitive_regression_model_covid_tolerant end

    def separating_heating_and_non_heating_days_explanation_html
      %{
        <h2>
          Separating heating and non-heating days
        </h2>
        <p>
          The first stage of the modelling process is to try to separate heating
          and non-heating days. This is because the regression modelling for
          heating and non-heating days is quite different. This separation allows
          different regresison models to be applied to the 2 modes of gas/storage
          heater consumption.
        </p>
        <p>
          The process is difficult to automate as the data is often messy, so
          sometimes the automatically modelling needs to be manually overwritten
          by a meter attribute. This often occurs where there is no clear distinction
          between days when the heating is on and off:
          <ul>
            <li>
                sometimes if the heating is left on all year it can be difficult to understand
                what is going on at a school, and impossible to identiy whether the heating
                has ever been turned off. This gets more difficult the further north you
                go where you would expect longer heating seasons.
            </li>
            <li>
                where a school has very good thermostatic control, or working daytime setback
                (the boiler turns off when the outside temperature for example reaches 15C),
                there is not an abrupt drop in energy consumption which is what the modelling
                is looking for to determine what is a heating and what is a non-heating day
            </li>
            <li>
                where a school has very poor thermostatic control, where there is limited relationship
                between the outside temperature and daily heating energy consumption
            </li>
            <li>
              where the building manager occasionally turns off the heating half way through the school
              day in mild weather
            </li>
            <li>
              where there has been a substantial change in heating or hot water control or a new boiler
              half way through the most recent year - as happened ata number of schools between March 2020
              and August 2020 due to COVID
            </li>
          </ul>
        </p>
        <p>
        The process starts by sampling daily gas or storage heater consumption during the summer in June,
        July and August. It assumes the heating is off during these months and then models this
        daily consumption calculating the standard devation of this data, to imply a range of
        daily consumption for daily heating days, and then assumes any consumption above this
        range is a &quot;heating&quot; day.
      }
    end

    def type_of_heating_model_html
      %{
        <h2>Chosen Non Heating Separation Model Type</h2>
        <blockquote>
            The model currently chosen for this meter is the
            <%= model.non_heating_model_type_description.to_s %> model.
        </blockquote>
        <p>
          This model can be overridden if it isn&quot;t working using either
          of the following meter attributes:
          <ul>
            <li>heating_non_heating_day_fixed_kwh_separation</li>
            <li>heating_non_heating_day_separation_model_override</li>
          </ul>
        </p>
      }
    end

    def heating_non_heating_separation_subsequent_3_chart_introduction_html
      %{
        <p>
            The next 3 pairs of 2 charts show 3 different models used for separating
            heating and non heating data, in order of their effectiveness:
            <ol>
              <li>regression model ignoring COVID lockdown periods, using summer 2019 if available</li>
              <li>regression model</li>
              <li>a very simplistic model that assumes non-heating day consumption is not corrleated with outside temperature</li>
            </ol>
            Each pair of charts consists of a thermostatic scatter chart and a seasonal heating chart for each of the models.
        </p>
      }
    end

    def heating_non_heating_separation_covid_model_chart_introduction_html
      %{
        <h3>regression model ignoring COVID lockdown periods</h3>
        <p>
            This first chart uses a model which samples school day consumption
            in June, July and August avoiding the COVID lockdown in 2020 if
            data is available:
        </p>
      }
    end

    def default_model_explanation_html
      %{
        <p>
          This is the default model unless manually overwridden with meter attributes.
        <p>
        <p>
          Look at the points on the scatter chart, has is correctly or reasonably
          separated heating from non heating days? If not you will need to apply
          meter attributes.
        </p>
      }
    end

    def generate_valid_advice
      html_components = [
         separating_heating_and_non_heating_days_explanation_html,
         type_of_heating_model_html,
         heating_non_heating_separation_subsequent_3_chart_introduction_html,
         heating_non_heating_separation_covid_model_chart_introduction_html,
         model_results_html
      ]

      @header_advice = generate_html_from_array_adding_body_tags(html_components, binding)

      @footer_advice = generate_html(default_model_explanation_html, binding)
    end
  end

  class SeasonalHeatingNonHeatingSeparationCovidModel < HeatingNonHeatingSeparationAdviceBase
    def generate_valid_advice
      @header_advice = nil_advice
      @footer_advice = nil_advice
    end
  end

  class HeatingNonHeatingSeparationRegressionModel < HeatingNonHeatingSeparationAdviceBase
    def model_type; :temperature_sensitive_regression_model end

    def vanilla_regression_model_chart_explanation_html
      %{
        <p>
          This chart uses the same model as that of the &apos;COVID model&apos; above
          but does&apos;nt skip COVID lockdown periods. If there is not enough meter
          reading history for the COVID model to go back a year then the 2 charts and
          the model results will be identical.
        </p>
      }
    end

    def generate_valid_advice
      html_components = [
        vanilla_regression_model_chart_explanation_html,
        model_results_html
      ]

      @header_advice = generate_html_from_array_adding_body_tags(html_components, binding)

      @footer_advice = nil_advice
    end
  end

  class SeasonalHeatingNonHeatingSeparationRegressionModel < HeatingNonHeatingSeparationAdviceBase
    def generate_valid_advice
      @header_advice = nil_advice
      @footer_advice = nil_advice
    end
  end

  class HeatingNonHeatingSeparationNonRegressionModel < HeatingNonHeatingSeparationAdviceBase
    def model_type; :fixed_single_value_temperature_sensitive_regression_model end
    def vanilla_regression_model_chart_explanation_html
      %{
        <p>
          Unlike the previous 2 models assume the summer hot water has some correlation
          with outside temperatures, this one does not. Sometimes it achieves better
          separation than the other two models.
        </p>
      }
    end

    def generate_valid_advice
      html_components = [
        vanilla_regression_model_chart_explanation_html,
        model_results_html
      ]

      @header_advice = generate_html_from_array_adding_body_tags(html_components, binding)

      @footer_advice = nil_advice
    end
  end

  class SeasonalHeatingNonHeatingSeparationNonRegressionModel < HeatingNonHeatingSeparationAdviceBase
    def choosing_model_decision_html
      %{
        <p>
          You need to review all 3 pairs of charts and work out which model is working best.
          If the first model which takes COVID into account is working well then you don&apos;t
          need to do anything.
        </p>
        <p>
          If the model is not working well then you need to pick one of the other two models
          and set a meter attribute. If none of the models is working then you will need
          to set a manual override.
        </p>
        <p>
          Additionally, sometimes an issue with a model can be fixed by setting a
          meter &apos;function&apos; type attribute to tell the model that there is
          either no heating on this meter, or it is heating only.
        </p>
        <p>
          The choice of meter overrides are as follows:
          <ul>
            <li></li>
          </ul>
        </p>
      }
    end

    def generate_valid_advice
      html_components = [choosing_model_decision_html]
      @header_advice = generate_html_from_array_adding_body_tags(html_components, binding)
      @footer_advice = nil_advice
    end
  end

  class ModelFittingIntroductionAndCategorisation < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h2>
            Modelling Process
          </h2>
          <p>
              The remainder of this web page presents the modelling calculations:
          </p>
          <h3>
              Categorisation process
          </h3>
          <p>
              This first chart shows Energy Spark's first attempt at categorising the gas
              consumption over the last year:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

        @header_advice = generate_html(header_template, binding)

        footer_template = %{
          <%= @body_start %>
            <p>
              Into heating and non-heating days using the simplest regression model. The
              x axis represents the average outside temperature for a day, the y-axis the
              daily gas consumption. Each point presents a day.
            </p>
            <p>
                The 'heating_occupied_all_days' points represent the winter gas consumption
                on days when the school is occupied. The 'summer_occupied_all_days' points
                represent the summer hot water and kitchen usage. The better the
                thermostatic control the closer the heating_occupied_all_days points should
                be to a line, which runs diagonally from a high point (left hand side,
                lowest temperature), to a low point (right hand side, highest temperature).
            </p>
            <p>
                If the summer_occupied_all_days also slopes downwards left to right it
                might be an indication that the school's hot water pipework or boiler is
                poorly insulated, as it indicates high hot water/kitchen gas consumption in
                colder weather, which suggests more heat is being lost somewhere.
            </p>
            <p>
                This chart is useful to check whether the statistical process which is
                being used to separate heating and non-heating days has worked correctly.
                If it appears poor, then some of the model controls will need manually
                overwriting (see later).
            </p
          <%= @body_end %>
        }.gsub(/^  /, '')

        @footer_advice = generate_html(footer_template, binding)
    end
  end

  class ModelFittingSimpleAllCategorisations < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h3>
            Simple Categorisation - all categories
          </h3>
          <p>
              This is just a repeat of the above but includes the summer and winter
              modelling for weekends and holidays as well. The chart can sometimes be
              more difficult to read and interpret.
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @header_advice = generate_html(header_template, binding)

      footer_template1 = %{
        <%= @body_start %>
          <p>
            The table below presents the regression models for each category:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      footer_template2 = regression_parameters_html_table(simple_model)

      footer_template3 = %{
          <p>
              The example prediction is calculated as follows kWh = A + B * the outside
              temperature.
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @footer_advice  = generate_html(footer_template1, binding)
      @footer_advice += footer_template2
      @footer_advice += generate_html(footer_template3, binding)
    end
  end

  class ModelFittingThermallMassiveModelSchoolDay < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h3>
              Thermally massive model - winter versus summer school day gas consumption
          </h3>
          <p>
              This chart is for an alternative model which splits heating consumption
              into days of the week. This model generally
              provides a better over all fit for schools, as they generally need more
              heating at the start of the week than the end of the week:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @header_advice = generate_html(header_template, binding)

      @footer_advice = nil_advice
    end
  end

  class ModelFittingThermallMassiveModelAllCategorisations < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h3>
              Thermally massive model - all categories
          </h3>
          <p>
            This is the same model as the chart above, but includes weekends and holidays
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @header_advice = generate_html(header_template, binding)

      footer_template1 = %{
        <%= @body_start %>
          <p>
              The modelled parameters are as follows:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      footer_template2 = regression_parameters_html_table(thermally_massive_model)

      @footer_advice  = generate_html(footer_template1, binding)
      @footer_advice += footer_template2
    end
  end

  class ModelFittingModellingDecision < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      min_simple_model_samples = AnalyseHeatingAndHotWater::MINIMUM_SAMPLES_FOR_SIMPLE_MODEL_TO_RUN_WELL
      min_massive_model_samples =  AnalyseHeatingAndHotWater::MINIMUM_SAMPLES_FOR_THERMALLY_MASSIVE_MODEL_TO_RUN_WELL

      header_template1 = %{
        <%= @body_start %>
          <h2>
            Modelling decision
          </h2>
          <p>
            Once Energy Sparks has calculated both models - the simple one where all
            days of the week are treated equally, and the 'thermally massive' model
            where the days of the week are dealt with separately, it then makes a
            decision on how close each of the models fits to the real data. By comparing
            the average R2 figures, and the percent standard deviation of the CUSUM.
          </p>
          <p>
            For this school, the two models produced the following:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      header_template3 = %{
        <%= @body_start %>
          <% if overridden_model? %>
            <p>
              <strong>******** The automatically fitted models have been overridden >********</strong>
            </p>
            <p>
              The reason for doing this was <%= best_model.reason %>
            </p>
          <% else %>
            <p>
              Given the '<%= best_model.name %>' model produced a better fit (higher R2, lower standard
              deviation percent), this model will be used by Energy Sparks going forward
              (today), unless in future new data suggests the other model is a better
              fit.
            </p>
            <p>
              <strong>Caveat:</strong> Both models are subject to a minimum number of samples which are
              required for model stability. These are currently <%= min_simple_model_samples %> winter school day
              heating samples for the simple model, and <%= min_massive_model_samples %> for the thermally
              massive model (aggregate of Monday through Friday). These limits are also used for the availability
              of chart and alert data, where as a minimum the <%= min_simple_model_samples %> days required by
              the simple model will be required before certain model dependent functionality  will work.
            </p>
            <p>
                The CUSUM chart below represents the difference between the gas consumption
                as predicted by the model (A + B * temperature), and the real gas consumption
                over time, grouped by week:
            </p>
          <% end %>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @header_advice  = generate_html(header_template1, binding)
      @header_advice += model_standard_devation_table_html
      @header_advice += generate_html(header_template3, binding)
      @header_advice += regression_parameters_html_table(best_model) if overridden_model?

      @footer_advice = nil_advice
    end
  end

  class ModelFittingWinterHolidayHeating < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h3>
              Categorised modelling - more detail
          </h3>
          <p>
              The next few charts, show the modelling for holidays and weekends in
              isolation, as the charts can sometimes we difficult to interpret if all the
              data is presented at the same time:
          </p>
          <p>
              <strong>Winter holiday heating</strong>
          </p>
          <p>
              Ideally there shouldn't be too many holidays with the heating on, and the
              slope of the data should roughly mimic that of the school day winter gas
              consumption:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

        @header_advice = generate_html(header_template, binding)

        @footer_advice = nil_advice
    end
  end

  class ModelFittingWinterWeekendHeating < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <p>
              <strong>Winter weekend heating</strong>
          </p>
          <p>
              Again, unless the school is occupied at the weekend, there should be too
              many days at the weekend with the heating on in the last year. The only
              good reason for the heating being on is frost protection when the heating
              might come on at an outside temperature of between 4C and 8C, but only on
              enough to increase the internal temperature of the building 10C, not the
              full occupancy temperature of 20C. So, in this circumstance, you might only
              expect points on the far left of the chart where the temperature is low,
              and these points might be about half of the values winter school days, to
              reflect the fact that the building is only being heated to 10C rather than
              20C.
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @header_advice = generate_html(header_template, binding)

      @footer_advice = nil_advice
    end
  end

  class ModelFittingSummerSchoolDayAndHoliday < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <p>
            <strong>Summer holiday and school day hot water and kitchen</strong>
          </p>
          <p>
            There are two set of data on this chart, to contrast occupied and
            non-occupied days during the summer. Ideally the hot water should be turned
            off during the holidays to save energy, so there shouldn't be too many
            holiday days on this chart:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

        @header_advice = generate_html(header_template, binding)

        footer_template = %{
          <%= @body_start %>
            <p>
                Points to note:
            </p>
            <ul>
              <li>
                If the points slope downwards from left to right it might indicate
                the hot water pipework is poorly insulated as more gas is required to
                compensate for lost heat in the pipework in colder weather
              </li>
              <li>
                The vertical difference between the school day and holiday
                consumption is an indication of the efficiency of the hot water system -
                the closer the points are together the less efficient the hot water system
                is
              </li>
              <li>
                Whether the hot water system is turned off or not, the school should have a
                legionella flushing policy in place for the end of the summer holidays.
              </li>
            </ul>
          <%= @body_end %>
        }.gsub(/^  /, '')

        @footer_advice = generate_html(footer_template, binding)
    end
  end

  class ModelFittingSummerWeekend < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <p>
            <strong>Summer weekend hot water</strong>
          </p>
          <p>
            Ideally, unless the school is occupied at weekends there shouldn't be any
            points on this chart.
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @header_advice = generate_html(header_template, binding)

      @footer_advice = nil_advice
    end
  end

  class ModelFittingMinimalDailyConsumption < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <p>
            <strong>Days of very low consumption</strong>
          </p>
          <p>
            Before Energy Sparks does its modelling calculations, it cleans up the data
            by removing all the days with very low gas consumption; these are included
            in this chart:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @header_advice = generate_html(header_template, binding)

      footer_template = %{
        <%= @body_start %>
          <p>
            Hopefully the chart should contain very few points, or not be displayed
            (indicating no points), if there are a large number of small non-zero
            points it might indicate for example the school boilers still have pilot
            lights or there is a small gas-powered hot water boiler somewhere in the
            school which is coming on. This is generally an indication of very old
            equipment, as pilot lights were replaced by electronic ignition in boiler
            designs more than 30 years ago.
        </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @footer_advice = generate_html(footer_template, binding)
    end
  end

  class ModelFittingCUSUMAnalysisSimpleModel < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h3>
              CUSUM Analysis - simple model
          </h3>
          <p>
              <a
                  href="https://www.sustainabilityexchange.ac.uk/files/degree_days_for_energy_management_carbon_trust.pdf"
                  target="_blank"
              >
                  Cusum (culmulative sum) graphs
              </a>
              shows how the school's actual gas consumption differs from the predicted
              gas consumption (see the explanation about the formula for the trend line
              in the thermostatic graph above).
          </p>
          <p>
              The graph is used by energy assessors to help them understand why a
              school's heating system might not be working well. It also allows them to
              see if changes in a school like a new more efficient boiler or reduced
              classroom temperatures has reduced gas consumption as it removes the
              variability caused by outside temperature from the graph.
          </p>
          <p>
              This is the cusum chart for the simpler model:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @header_advice = generate_html(header_template, binding)

      @footer_advice = nil_advice
    end
  end

  class ModelFittingCUSUMAnalysisThermallMassiveModel < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h3>
              CUSUM Analysis - thermal mass model
          </h3>
          <p>
              And this is the chart for the model with the winter school days are split
              into days of the week, in general it should show a smaller divergence from
              zero than the simple model.
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

        @header_advice = generate_html(header_template, binding)

        footer_template1 = %{
          <%= @body_start %>
            <p>
                This divergence is represented both as an absolute standard deviation and a
                percentage deviation:
            </p>
          <%= @body_end %>
        }.gsub(/^  /, '')

        footer_template2 = model_standard_devation_table_html

        @footer_advice = generate_html(footer_template1, binding) + footer_template2
    end
  end

  class ModelFittingSplittingHeatingAndNonHeating < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
        <p>
          <%= school_name %> has its heating on for <%= school_heating_days %> school days each year,
          which is <%= school_heating_day_adjective(school_heating_days) %>,
          the average for schools is <%= average_school_heating_days %> days
          The school has its heating on for <%= non_school_heating_days %> non-school days each year,
          which is <%= non_school_heating_day_adjective(non_school_heating_days) %>,
          the average for schools is <%= average_non_school_heating_days %> days
      <p>
        <%= @body_end %>
      }.gsub(/^  /, '')

        @header_advice = generate_html(header_template, binding)

        footer_template = %{
          <%= @body_start %>
            <p>
              Schools are able to reduce their heating consumption by reducing the length of the
              heating season, remembering to turn the heating off in the Spring when warm weather
              arrives and only on again in the Autumn when it gets cold. If the heating
              is left on in warm weather, then it&apos;s often wasted as classroom windows
              are opened to stop classrooms getting too hot, rather than the radiators being
              turned off.
            </p>
            <p>
              In the summer when the heating is off then the remaining gas consumption
              is typically for hot water and in some schools for kitchens (which should
              only consume gas in the mornings).
            </p>
            <p>
              This chart also makes it obvious if the heating has been left on during holidays.
              Has your school left its heating on during holidays in the last year
              and when did it turn the heating off in the summer?
            </p>

          <%= @body_end %>
        }.gsub(/^  /, '')

        @footer_advice = generate_html(footer_template, binding)
    end
  end

  class ModelFittingSplittingIntoCategories < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <p>
            This chart splits the last year into categories used for modelling:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @header_advice = generate_html(header_template, binding)

      @footer_advice = nil_advice
    end
  end

  class ModelFittingSplittingIntoCategoriesPieChart < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <p>
            This chart splits the last year into categories used for modelling:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

        @header_advice = generate_html(header_template, binding)

        footer_template = %{
          <%= @body_start %>
            <p>
              This table shows the energy used for the last year in each of these groupings
            </p>
          <%= @body_end %>
        }.gsub(/^  /, '')

        @footer_advice = generate_html(footer_template, binding)
    end
  end

  class ModelFittingSplittingHeatingAndNonHeatingPieChart < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      header_template = %{
        <%= @body_start %>
          <h2>
              Hot Water Versus Heating Analysis
          </h2>
          <p>
              This is an experimental calculation to try to breakdown the school's gas
              consumption between heating and hot water. It assumes the hot water
              consumption as calculated over the summer is representative of year around
              consumption, it calculates this, and assumes the difference (excess) is the
              heating consumption for the school:
          </p>
        <%= @body_end %>
      }.gsub(/^  /, '')

      @header_advice = generate_html(header_template, binding)

      @footer_advice = nil_advice
    end
  end

  class ModelFittingTemplateDoNothing < ModelFittingAdviceBase
    include Logging

    def generate_valid_advice
      @header_advice = nil_advice
      @footer_advice = nil_advice
    end
  end
end

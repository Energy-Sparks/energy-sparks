class HotWaterFormattingBase
  private def format(unit, value, medium, comprehension = :ks2)
    return nil if value.nil?
    medium.nil? ? value : FormatEnergyUnit.format(unit, value, medium, false, true, comprehension)
  end

  def self.formatted_pound(medium)
    case medium
    when :html
      '&pound;'
    when :test
      '£'
    else
      '£'
    end
  end
end

class HotWaterDayTypeTableFormatting < HotWaterFormattingBase
  def initialize(hotwater_investment)
    @daytime_breakdown = hotwater_investment.hotwater_model.daytype_breakdown_statistics
  end

  def daytype_breakdown_table(medium)
    header = [
      '',
      'Daily kWh',
      'Daily ' + self.class.formatted_pound(medium),
      'Annual kWh',
      'Annual ' + self.class.formatted_pound(medium)
    ]
    rows = [
        row_data('School day (open)',   :school_day_open,    medium),
        row_data('School day (closed)', :school_day_closed,  medium),
        row_data('Weekends',            :weekend,           medium),
        row_data('Holidays',            :holiday,           medium)
    ]
    totals = row_data('Total',          :total, medium)

    medium == :html ? HtmlTableFormatting.new(header, rows, totals).html : [header, rows, totals]
  end

  def row_data(name, type, medium = :text)
    [
      name,
      format(:kwh,  @daytime_breakdown[:daily][:kwh][type],   medium),
      format(:£,    @daytime_breakdown[:daily][:£][type],     medium),
      format(:kwh,  @daytime_breakdown[:annual][:kwh][type],  medium),
      format(:£,    @daytime_breakdown[:annual][:£][type],    medium)
    ]
  end

  def find_data_in_table(key, composite_key)
    @daytime_breakdown[key[1]][key[2]][key[0]]
  end

  def self.template_variables
    variables = {}
    %i[school_day_open school_day_closed weekend holiday total].each do |daytype|
      %i[daily annual].each do |period|
        %i[kwh £].each do |unit|
          composite_key = [daytype, period, unit]
          key = composite_key.join('_').to_sym
          variables[key] = {
            description:  key.to_s.humanize + ' (auto generated from table)',
            units:        unit,
            key:          composite_key
          }
        end
      end
    end
    variables.delete(:total_daily_kwh)
    variables.delete(:total_daily_£)
    variables
  end
end

class HotWaterInvestmentTableFormatting < HotWaterFormattingBase

  DATACOLUMNS = {
    choice:             { name: 'Choice'                                },
    annual_kwh:         { name: 'Annual kWh',         units:  :kwh      },
    annual_£:           { name: 'Annual Cost £',      units:  :£        },
    annual_co2:         { name: 'Annual CO2/kg',      units:  :co2      },
    efficiency:         { name: 'Efficiency',         units:  :percent  },
    saving_£:           { name: 'Saving £',           units:  :£        },
    saving_£_percent:   { name: 'Saving £ percent',   units:  :percent  },
    saving_co2:         { name: 'Saving CO2',         units:  :co2      },
    saving_co2_percent: { name: 'Saving CO2 percent', units:  :percent  },
    capex:              { name: 'Capital Cost',       units:  :£        },
    payback_years:      { name: 'Payback (years)',    units:  :years    }
  }.freeze

  def initialize(hotwater_data)
    @hotwater_data = hotwater_data
  end

  def self.template_variables
    variables = {}
    DATACOLUMNS.each do |column_key, config|
      next unless config.key?(:units)
      %i[existing_gas gas_better_control point_of_use_electric].each do |choice|
        composite_key = [choice, column_key]
        key = composite_key.join('_').to_sym
        variables[key] = {
          description:  key.to_s.humanize + ' (auto generated from table)',
          units:        config[:units],
          key:          composite_key
        }
      end
    end

    # remove null results
    %i[
      existing_gas_saving_£
      existing_gas_saving_£_percent
      existing_gas_saving_co2
      existing_gas_saving_co2_percent
      existing_gas_payback_years
    ].each { |key| variables.delete(key) }

    variables
  end

  def find_data_in_table(key, composite_key)
    @hotwater_data[key[0]][key[1]]
  end

  def full_analysis_table(medium = :text)
    header = DATACOLUMNS.map { |_type, config| config[:name].gsub('£', self.class.formatted_pound(medium)) }
    rows = [
      full_analysis_row('Current setup',                  @hotwater_data[:existing_gas], medium),
      full_analysis_row('Improved boiler control',        @hotwater_data[:gas_better_control], medium),
      full_analysis_row('Point of use electric heaters',  @hotwater_data[:point_of_use_electric], medium)
    ]
    medium == :html ? HtmlTableFormatting.new(header, rows).html : [header, rows, nil]
  end

  private def full_analysis_row(name, row_data, medium)
    [
      name,
      format(:kwh,            row_data[:annual_kwh],         medium),
      format(:£,              row_data[:annual_£],           medium),
      format(:co2,            row_data[:annual_co2],         medium),
      format(:percent,        row_data[:efficiency],         medium),
      format(:£,              row_data[:saving_£],           medium),
      format(:percent,        row_data[:saving_£_percent],   medium),
      format(:co2,            row_data[:saving_co2],         medium),
      format(:percent,        row_data[:saving_co2_percent], medium),
      format(:£,              row_data[:capex],              medium),
      format(:years_decimal,  row_data[:payback_years],      medium),
    ]
  end
end

class OneDaysCostData
  attr_reader :standing_charges, :total_standing_charge, :one_day_total_cost
  attr_reader :all_costs_x48
  # these could be true, false or :mixed
  attr_reader :system_wide, :default
  # either a single tariff, or an array for tariffs for a combined cost
  attr_reader :tariff

  def initialize(rates_x48:, standing_charges:, differential:, system_wide:, default:, tariff: )
    @all_costs_x48    = rates_x48
    @standing_charges = standing_charges
    @differential     = differential
    @system_wide      = system_wide
    @default          = default
    @tariff           = tariff

    @total_standing_charge = standing_charges.empty? ? 0.0 : standing_charges.values.sum
    @one_day_total_cost = total_x48_costs + @total_standing_charge
  end

  def to_s
    "OneDaysCostData: Tcost #{one_day_total_cost} skeys: #{standing_charges.empty? ? '' : standing_charges.keys.map(&:to_s).join(',')} scT: #{total_standing_charge&.round(0)}"
  end

  def costs_x48
    @costs_x48 ||= AMRData.fast_add_multiple_x48_x_x48(@all_costs_x48.values)
  end

  def total_x48_costs
    @total_x48_costs ||= costs_x48.sum
  end

  def cost_x48(type)
    @all_costs_x48[type]
  end

  def differential_tariff?
    @differential
  end

  def rates_at_half_hour(halfhour_index)
    @all_costs_x48.map { |type, £_x48| [type, £_x48[halfhour_index]] }.to_h
  end

  def bill_components
    @bill_components ||= @all_costs_x48.keys.concat(@standing_charges.keys)
  end

  def bill_component_costs_per_day
    @bill_component_costs_per_day ||= calculate_bill_component_costs_per_day
  end

  # used for storage heater disaggregation
  def scale_standing_charges(percent)
    @standing_charges = @standing_charges.transform_values { |value| value * percent }
    @one_day_total_cost -= @total_standing_charge * (1.0 - percent)
    @total_standing_charge *= percent
    @bill_component_costs_per_day.merge!(@standing_charges)
  end

  # Create new instance by combining an array of existing cost objects
  def self.combine_costs(costs)
    OneDaysCostData.new(
      rates_x48:        merge_costs_x48(costs.map(&:all_costs_x48)),
      standing_charges: combined_standing_charges(costs),
      differential:     costs.any?{ |c| c.differential_tariff? },
      system_wide:      combined_system_wide(costs),
      default:          combined_default(costs),
      tariff:           costs.map { |c| c.tariff }
    )
  end

  private_class_method def self.combined_system_wide(costs)
    return true  if costs.all? { |c| c.system_wide == true }
    return false if costs.all? { |c| c.system_wide != true }
    :mixed
  end

  private_class_method def self.combined_default(costs)
    return true  if costs.all? { |c| c.default == true }
    return false if costs.all? { |c| c.default != true }
    :mixed
  end

  # merge array of hashes of x48 costs
  private_class_method def self.merge_costs_x48(arr_of_type_to_costs_x48)
    totals_x48_by_type = Hash.new{ |h, k| h[k] = [] }

    arr_of_type_to_costs_x48.each do |type_to_costs_x48|
      type_to_costs_x48.each do |type, c_x48|
        totals_x48_by_type[type].push(c_x48)
      end
    end

    totals_x48_by_type.transform_values{ |c_x48_array| AMRData.fast_add_multiple_x48_x_x48(c_x48_array) }
  end

  private_class_method def self.combined_standing_charges(costs)
    combined_standing_charges = Hash.new(0.0)
    costs.each do |cost|
      cost.standing_charges.each do |type, value|
        combined_standing_charges[type] += value
      end
    end
    combined_standing_charges
  end

  private

  def calculate_bill_component_costs_per_day
    bill_component_costs_per_day = @all_costs_x48.transform_values{ |£_x48| £_x48.sum }
    bill_component_costs_per_day.merge!(standing_charges)
  end
end

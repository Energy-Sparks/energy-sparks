class AlertTypeFactory
  def initialize(alert_hash)
    @alert_hash = alert_hash
  end

  def create
    @alert_hash.each do |alert|

      next if alert[:category].nil?
      category = alert[:category].parameterize.underscore.to_sym
      subcategory = alert[:subcategory].parameterize.underscore.to_sym
      long_term = alert[:term] == 'Long'
      daily_frequency = alert[:frequency].to_i

      al = AlertType.where(title: alert[:alert], category: category, sub_category: subcategory, long_term: long_term, analysis_description: alert[:analysis], sample_message: alert[:sample_message], daily_frequency: daily_frequency).first_or_create
      pp al
    end
  end
end


# {:category=>"Gas", :subcategory=>"Hot Water", :alert=>"Hot Water Inefficient", :term=>"Long", :sample_message=>"Your hot water system is only x% efficient, click here for suggestions on how to improve", :analysis=>"Scan across August Holidays historically looking for in and out of holiday use, return an efficiency measure", nil=>nil}
# {:category=>"Gas", :subcategory=>"Hot Water", :alert=>"Hot Water Left on Over Holidays and Weekends", :term=>"Long", :sample_message=>"You often leave your hot water on over holidays and weekends, this is costing you £5 and £6 respectively, click here for suggesitons on how to reduce this", :analysis=>"Scan all weekends and holidays, sum up gas usage when temp above 4C (heating frost protection)", nil=>nil}
# {:category=>"Gas", :subcategory=>"Hot Water", :alert=>"Hot water left on over holidays", :term=>"Short", :sample_message=>"Warning: you have left your hot water on over the holidays", :analysis=>"If in a holiday, and have full day of data, and not frosty, alert message if gas usage above a threshold", nil=>nil}
# {:category=>"Gas", :subcategory=>"Heating", :alert=>"Left on over holidays and weekends", :term=>"Long", :sample_message=>"You often leave your Heating on over holidays and weekends, this is costing you £5 and £6 respectively, click here for suggesitons on how to reduce this", :analysis=>"Scan all weekends and holidays, sum up gas usage when temp above 4C (heating frost protection)", nil=>nil}
# {:category=>"Gas", :subcategory=>"Frost Protection", :alert=>"Frost protection using too much gas", :term=>"Long", :sample_message=>"Your frost protection system may be using too much gas, please check its settings", :analysis=>"Scan all winter weekends and holidays where temperature below and above 4C, determine weekends where fronst protection on, analyse usage, return dates when on; potentially extend of school days out of hours", nil=>nil}
# {:category=>"Gas", :subcategory=>"Optimium Start", :alert=>"Optimum Start Starting Too Early", :term=>"Long", :sample_message=>"Your boiler is starting too early in the morning", :analysis=>"Develop basic heat up model, back out proportion of heat used before occupancy time (seem associated gdoc)", nil=>nil}
# {:category=>"Gas", :subcategory=>"Heating Turn On/Off", :alert=>"Advanced warning of warm or cold weather", :term=>"Short", :sample_message=>"The weather forecast for next week suggests an average temperature of X, you should consider turning your boiler on/off", :analysis=>"Some form of heuristic looking at the next 5 working days weather, ex holidays", nil=>nil}
# {:category=>"Gas", :subcategory=>"Heating Off", :alert=>"Upcoming holiday", :term=>"Short", :sample_message=>"There is a holiday coming up, please remeber to turn the heating off", :analysis=>", some reference to whether frost protection is configured?", nil=>nil}
# {:category=>"Gas ", :subcategory=>"Change in consumption", :alert=>"Usage up or down", :term=>"Short", :sample_message=>"Your gas usage has increased by x% since last week, please investigate (if this continues for the rest of the year it might cost an additional Y%)", :analysis=>"Requires regression based model to adjust for temperatures", nil=>nil}
# {:category=>"Electricity", :subcategory=>"Change in consumption", :alert=>"Usage up or down", :term=>"Short", :sample_message=>"Your electricity usage has increased by x% since last week, please investigate (if this continues for the rest of the year it might cost an additional Y%)", :analysis=>"Requires regression based model to adjust for temperatures", nil=>nil}
# {:category=>"Electricity", :subcategory=>"Change in baseload consumption", :alert=>"Out of hours usage up or down", :term=>"Short & long", :sample_message=>"Your out of hours usage has increased by x% since last week, please investigate (if this continues for the rest of the year it might cost an additional Y%)", :analysis=>nil, nil=>nil}
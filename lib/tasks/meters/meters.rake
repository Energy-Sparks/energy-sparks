namespace :meters do

  def real_meters
    {
      10274100    => { heating_non_heating_day_separation_model_override: :either }, # Durham Sixth
      10302505  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Green Lane
      10307706  => { heating_non_heating_day_separation_model_override: :no_idea }, # King James
      10308203  => { function_switch: :heating_only }, # King James
      10308607  => { function_switch: :heating_only }, # King James
      10328108    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham Sixth
      10545307  => { heating_non_heating_day_separation_model_override: :either }, # Trinity
      11139604  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
      11160707  => { function_switch: :heating_only }, # Toft Hill
      12192501    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham St M
      12192602    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham St M
      12193907    => { function_switch: :heating_only }, # Durham St
      1335642507  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Wingate
      13605606    => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # christ church
      13610307  => { function_switch: :heating_only }, # Oakfield
      13610408  => { heating_non_heating_day_separation_model_override: :either }, # Oakfield
      13610902    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Critchill
      13947702  =>  { heating_non_heating_day_fixed_kwh_separation: 140.0 }, # Wooton St Peters
      14349002  => { heating_non_heating_day_separation_model_override: :no_idea }, # Red Rose
      14493806  => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
      14494404  => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
      14601603  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Portsmouth
      14601805  => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
      15224503  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Robsack
      15234304  => { heating_non_heating_day_separation_model_override: :either }, # Sacred Heart
      15496604  => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
      15718809    => { function_switch: :heating_only }, # All Saints
      15719508    => { heating_non_heating_day_fixed_kwh_separation: 150.0 }, # All Saints
      16747608  => { heating_non_heating_day_separation_model_override: :either }, # St Philips
      16747810  => { heating_non_heating_day_separation_model_override: :either }, # St Philips
      180006  => { heating_non_heating_day_fixed_kwh_separation: 100.0 }, # Royal High
      180208  => { function_switch: :heating_only }, # Royal High
      180410  => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
      180601  => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
      180702  => { function_switch: :heating_only }, # Royal High
      180803  => { function_switch: :heating_only }, # Royal High
      181109  => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
      181210  => { function_switch: :heating_only }, # Royal High
      181401  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Royal High
      181502  => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
      19161200  => { function_switch: :heating_only }, # St Louis
      2148244308    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # athelston
      2155853706  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Eccleshall
      2163409301  => { heating_non_heating_day_separation_model_override: :either }, # Whiteways
      47939506  => { heating_non_heating_day_separation_model_override: :no_idea }, # Saltford
      61561206  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Kensington Prep
      620361806   => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
      6319210   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
      6319300   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Mundella
      6326701       => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # bankwood
      6354605   => { heating_non_heating_day_separation_model_override: :either }, # St Thomas of C
      6460705     => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Coit
      6500803   => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Walkley
      6504306       => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # brunswick
      6508101       => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # balliefield
      6517203   => { heating_non_heating_day_separation_model_override: :either }, # King Edward
      6538402   => { function_switch: :heating_only }, # Mossbrook
      6554602   => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Ecclesfield
      6615809   => { heating_non_heating_day_fixed_kwh_separation: 235.0 }, # abbey lane
      67285306  => { heating_non_heating_day_separation_model_override: :either }, # St Benedict
      68351006  => { function_switch: :heating_only }, # Portsmouth
      74118502  => { heating_non_heating_day_separation_model_override: :either }, # Long Furlong
      75869205  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Ringmer
      76187307  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
      78503110    => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Ditchling
      78575708  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Saundersfoot
      82043504  => { function_switch: :kitchen_only }, # St Richards C
      82044001  => { function_switch: :heating_only }, # St Richards C
      8814676600  => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
      8817452200  =>  { function_switch: :heating_only }, # Hunwick
      8834264005  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Bedes
      8879383007  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Durham Sixth
      8903472804  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # The Durham Federation, good example
      8904906502  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # St Micolas
      8907137204  => { function_switch: :kitchen_only }, # The Haven
      8907148400  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # The Haven
      8908639402  => { heating_non_heating_day_fixed_kwh_separation: 200.0 }, # St Nicolas
      8913915100  => { function_switch: :heating_only }, # Little Horsted
      9088027004  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Pevensey
      9088174803    => { heating_non_heating_day_separation_model_override: :either }, # caldicot
      9090353207  => { heating_non_heating_day_separation_model_override: :either }, # St Bedes
      9091095306  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
      9102173605    => { heating_non_heating_day_separation_model_override: :no_idea }, # caldicot
      9109952508  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Golden Grove
      9120550903  =>  { heating_non_heating_day_fixed_kwh_separation: 350.0 }, # Woodthorpe
      9153680108  => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
      9158112702    => { heating_non_heating_day_fixed_kwh_separation: 400.0 }, # ribbon
      9178098904  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Prendaghast
      9188991203  => { heating_non_heating_day_separation_model_override: :either }, # Wivelsfield
      9209120604  => { heating_non_heating_day_separation_model_override: :either }, # Watercliffe Meadow
      9216058504  => { function_switch: :kitchen_only }, # Green Lane
      9216058605  => { function_switch: :heating_only }, # Green Lane
      9297324003  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Wybourne
      9305046403  => { function_switch: :heating_only }, # Red Rose
      9306088907  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Lamphey
      9308062001  => { heating_non_heating_day_separation_model_override: :either }, # Prince Bishop
      9330192104    => { heating_non_heating_day_fixed_kwh_separation: 125.0 }, # abbey lane
      9335373908  => { heating_non_heating_day_separation_model_override: :either }, # King James
      9337391909  => { heating_non_heating_day_fixed_kwh_separation: 500.0 }, # Walkley
      9377457904  => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
    }
  end

  def aggregated_gas
    {
      2125  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Red Rose
      2169  => { heating_non_heating_day_separation_model_override: :either }, # The Haven
      102692  => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
      106982    => { heating_non_heating_day_separation_model_override: :either }, # abbey lane
      107006  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
      107094  => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Walkley
      109348  => { heating_non_heating_day_fixed_kwh_separation: 2000.0 }, # Royal High
      114219  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Green Lane
      114230  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Durham St M
      114310    => { heating_non_heating_day_fixed_kwh_separation: 500.0 }, # Durham Sixth
      114491    => { heating_non_heating_day_fixed_kwh_separation: 150.0 }, # All Saints
      114612  => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
      116581  => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
      123087    => { heating_non_heating_day_separation_model_override: :no_idea }, # caldicot
      136770  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # King James
      136970  => { heating_non_heating_day_separation_model_override: :either }, # Oakfield
      143560  => { heating_non_heating_day_separation_model_override: :either }, # St Philips
      147894  => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
      8403344   => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # St Bedes
    }
  end

  def add_attribute_to_meter(meter, type, value, user)
    unless meter.meter_attributes.find_by(attribute_type: type, deleted_by_id: nil, replaced_by_id: nil)
      puts "Creating attribute for meter.."
      meter.meter_attributes.create!(attribute_type: type, reason: 'Script', input_data: value, created_by: user)
    end
  end

  def add_attribute_to_school(school, type, value, meter_types, user)
    unless school.meter_attributes.find_by(attribute_type: type, deleted_by_id: nil, replaced_by_id: nil)
      puts "Creating attribute for school.."
      school.meter_attributes.create!(attribute_type: type, reason: 'Script', input_data: value, meter_types: meter_types, created_by: user)
    end
  end

  def remove_attribute_from_meter(meter, type)
    if meter_attribute = meter.meter_attributes.find_by(attribute_type: type, deleted_by_id: nil, replaced_by_id: nil)
      puts "Removing attribute from meter.."
      meter_attribute.destroy!
    end
  end

  def remove_attribute_from_school(school, type)
    if meter_attribute = school.meter_attributes.find_by(attribute_type: type, deleted_by_id: nil, replaced_by_id: nil)
      puts "Removing attribute from meter.."
      meter_attribute.destroy!
    end
  end

  desc 'Adding heating non-heating attributes'
  task add_heating_non_heating_attributes: :environment do

    user = User.find(1)

    ActiveRecord::Base.transaction do

      real_meters.each do |mpxn, attrs|
        puts "#{mpxn}"
        if meter = Meter.find_by_mpan_mprn(mpxn)
          add_attribute_to_meter(meter, attrs.keys[0], attrs.values[0], user)
        else
          raise StandardError, "No meter found for #{mpxn}"
        end
      end

      aggregated_gas.each do |urn, attrs|
        puts "#{urn}"
        if school = School.find_by_urn(urn)
          add_attribute_to_school(school, attrs.keys[0], attrs.values[0], ["aggregated_gas"], user)
        else
          raise StandardError, "No school found for #{urn}"
        end
      end

    end

  end

  desc 'Removing heating non-heating attributes'
  task remove_heating_non_heating_attributes: :environment do

    ActiveRecord::Base.transaction do

      real_meters.each do |mpxn, attrs|
        puts "#{mpxn}"
        if meter = Meter.find_by_mpan_mprn(mpxn)
          remove_attribute_from_meter(meter, attrs.keys[0])
        else
          raise StandardError, "No meter found for #{mpxn}"
        end
      end

      aggregated_gas.each do |urn, attrs|
        puts "#{urn}"
        if school = School.find_by_urn(urn)
          remove_attribute_from_school(school, attrs.keys[0])
        else
          raise StandardError, "No school found for #{urn}"
        end
      end

    end

  end






end

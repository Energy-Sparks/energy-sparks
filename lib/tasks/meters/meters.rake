namespace :meters do
  def real_meters
    {
      10_274_100 => { heating_non_heating_day_separation_model_override: :either }, # Durham Sixth
      10_302_505 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Green Lane
      10_307_706 => { heating_non_heating_day_separation_model_override: :no_idea }, # King James
      10_308_203 => { function_switch: :heating_only }, # King James
      10_308_607 => { function_switch: :heating_only }, # King James
      10_328_108 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham Sixth
      10_545_307 => { heating_non_heating_day_separation_model_override: :either }, # Trinity
      11_139_604 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
      11_160_707 => { function_switch: :heating_only }, # Toft Hill
      12_192_501 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham St M
      12_192_602 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Durham St M
      12_193_907 => { function_switch: :heating_only }, # Durham St
      1_335_642_507 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Wingate
      13_605_606 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # christ church
      13_610_307 => { function_switch: :heating_only }, # Oakfield
      13_610_408 => { heating_non_heating_day_separation_model_override: :either }, # Oakfield
      13_610_902 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Critchill
      13_947_702 => { heating_non_heating_day_fixed_kwh_separation: 140.0 }, # Wooton St Peters
      14_349_002 => { heating_non_heating_day_separation_model_override: :no_idea }, # Red Rose
      14_493_806 => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
      14_494_404 => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
      14_601_603 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Portsmouth
      14_601_805 => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
      15_224_503 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Robsack
      15_234_304 => { heating_non_heating_day_separation_model_override: :either }, # Sacred Heart
      15_496_604 => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
      15_718_809 => { function_switch: :heating_only }, # All Saints
      15_719_508 => { heating_non_heating_day_fixed_kwh_separation: 150.0 }, # All Saints
      16_747_608 => { heating_non_heating_day_separation_model_override: :either }, # St Philips
      16_747_810 => { heating_non_heating_day_separation_model_override: :either }, # St Philips
      180_006 => { heating_non_heating_day_fixed_kwh_separation: 100.0 }, # Royal High
      180_208 => { function_switch: :heating_only }, # Royal High
      180_410 => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
      180_601 => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
      180_702 => { function_switch: :heating_only }, # Royal High
      180_803 => { function_switch: :heating_only }, # Royal High
      181_109 => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
      181_210 => { function_switch: :heating_only }, # Royal High
      181_401 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Royal High
      181_502 => { heating_non_heating_day_separation_model_override: :no_idea }, # Royal High
      19_161_200 => { function_switch: :heating_only }, # St Louis
      2_148_244_308 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # athelston
      2_155_853_706 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Eccleshall
      2_163_409_301 => { heating_non_heating_day_separation_model_override: :either }, # Whiteways
      47_939_506 => { heating_non_heating_day_separation_model_override: :no_idea }, # Saltford
      61_561_206 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Kensington Prep
      620_361_806 => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
      6_319_210 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
      6_319_300 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Mundella
      6_326_701 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # bankwood
      6_354_605 => { heating_non_heating_day_separation_model_override: :either }, # St Thomas of C
      6_460_705 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Coit
      6_500_803 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Walkley
      6_504_306 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # brunswick
      6_508_101 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # balliefield
      6_517_203 => { heating_non_heating_day_separation_model_override: :either }, # King Edward
      6_538_402 => { function_switch: :heating_only }, # Mossbrook
      6_554_602 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Ecclesfield
      6_615_809 => { heating_non_heating_day_fixed_kwh_separation: 235.0 }, # abbey lane
      67_285_306 => { heating_non_heating_day_separation_model_override: :either }, # St Benedict
      68_351_006 => { function_switch: :heating_only }, # Portsmouth
      74_118_502 => { heating_non_heating_day_separation_model_override: :either }, # Long Furlong
      75_869_205 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Ringmer
      76_187_307 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
      78_503_110 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Ditchling
      78_575_708 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Saundersfoot
      82_043_504 => { function_switch: :kitchen_only }, # St Richards C
      82_044_001 => { function_switch: :heating_only }, # St Richards C
      8_814_676_600 => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
      8_817_452_200 => { function_switch: :heating_only }, # Hunwick
      8_834_264_005 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Bedes
      8_879_383_007 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Durham Sixth
      8_903_472_804 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # The Durham Federation, good example
      8_904_906_502 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # St Micolas
      8_907_137_204 => { function_switch: :kitchen_only }, # The Haven
      8_907_148_400 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # The Haven
      8_908_639_402 => { heating_non_heating_day_fixed_kwh_separation: 200.0 }, # St Nicolas
      8_913_915_100 => { function_switch: :heating_only }, # Little Horsted
      9_088_027_004 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Pevensey
      9_088_174_803 => { heating_non_heating_day_separation_model_override: :either }, # caldicot
      9_090_353_207 => { heating_non_heating_day_separation_model_override: :either }, # St Bedes
      9_091_095_306 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
      9_102_173_605 => { heating_non_heating_day_separation_model_override: :no_idea }, # caldicot
      9_109_952_508 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Golden Grove
      9_120_550_903 => { heating_non_heating_day_fixed_kwh_separation: 350.0 }, # Woodthorpe
      9_153_680_108 => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
      9_158_112_702 => { heating_non_heating_day_fixed_kwh_separation: 400.0 }, # ribbon
      9_178_098_904 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Prendaghast
      9_188_991_203 => { heating_non_heating_day_separation_model_override: :either }, # Wivelsfield
      9_209_120_604 => { heating_non_heating_day_separation_model_override: :either }, # Watercliffe Meadow
      9_216_058_504 => { function_switch: :kitchen_only }, # Green Lane
      9_216_058_605 => { function_switch: :heating_only }, # Green Lane
      9_297_324_003 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Wybourne
      9_305_046_403 => { function_switch: :heating_only }, # Red Rose
      9_306_088_907 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Lamphey
      9_308_062_001 => { heating_non_heating_day_separation_model_override: :either }, # Prince Bishop
      9_330_192_104 => { heating_non_heating_day_fixed_kwh_separation: 125.0 }, # abbey lane
      9_335_373_908 => { heating_non_heating_day_separation_model_override: :either }, # King James
      9_337_391_909 => { heating_non_heating_day_fixed_kwh_separation: 500.0 }, # Walkley
      9_377_457_904 => { heating_non_heating_day_separation_model_override: :not_enough_data } # Wimbledon
    }
  end

  def aggregated_gas
    {
      2125 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Red Rose
      2169 => { heating_non_heating_day_separation_model_override: :either }, # The Haven
      102_692 => { heating_non_heating_day_separation_model_override: :not_enough_data }, # Wimbledon
      106_982 => { heating_non_heating_day_separation_model_override: :either }, # abbey lane
      107_006 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # Mundella
      107_094 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model }, # Walkley
      109_348 => { heating_non_heating_day_fixed_kwh_separation: 2000.0 }, # Royal High
      114_219 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Green Lane
      114_230 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model_covid_tolerant }, # Durham St M
      114_310 => { heating_non_heating_day_fixed_kwh_separation: 500.0 }, # Durham Sixth
      114_491 => { heating_non_heating_day_fixed_kwh_separation: 150.0 }, # All Saints
      114_612 => { heating_non_heating_day_separation_model_override: :either }, # St Richards C
      116_581 => { heating_non_heating_day_separation_model_override: :either }, # Portsmouth
      123_087 => { heating_non_heating_day_separation_model_override: :no_idea }, # caldicot
      136_770 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # King James
      136_970 => { heating_non_heating_day_separation_model_override: :either }, # Oakfield
      143_560 => { heating_non_heating_day_separation_model_override: :either }, # St Philips
      147_894 => { heating_non_heating_day_separation_model_override: :temperature_sensitive_regression_model }, # St Micolas
      8_403_344 => { heating_non_heating_day_separation_model_override: :fixed_single_value_temperature_sensitive_regression_model } # St Bedes
    }
  end

  def add_attribute_to_meter(meter, type, value, user)
    unless meter.meter_attributes.find_by(attribute_type: type, deleted_by_id: nil, replaced_by_id: nil)
      puts 'Creating attribute for meter..'
      meter.meter_attributes.create!(attribute_type: type, reason: 'Script', input_data: value, created_by: user)
    end
  end

  def add_attribute_to_school(school, type, value, meter_types, user)
    unless school.meter_attributes.find_by(attribute_type: type, deleted_by_id: nil, replaced_by_id: nil)
      puts 'Creating attribute for school..'
      school.meter_attributes.create!(attribute_type: type, reason: 'Script', input_data: value, meter_types: meter_types, created_by: user)
    end
  end

  def remove_attribute_from_meter(meter, type)
    if meter_attribute = meter.meter_attributes.find_by(attribute_type: type, deleted_by_id: nil, replaced_by_id: nil)
      puts 'Removing attribute from meter..'
      meter_attribute.destroy!
    end
  end

  def remove_attribute_from_school(school, type)
    if meter_attribute = school.meter_attributes.find_by(attribute_type: type, deleted_by_id: nil, replaced_by_id: nil)
      puts 'Removing attribute from meter..'
      meter_attribute.destroy!
    end
  end

  desc 'Adding heating non-heating attributes'
  task add_heating_non_heating_attributes: :environment do
    user = User.find(1)

    ActiveRecord::Base.transaction do
      real_meters.each do |mpxn, attrs|
        puts mpxn.to_s
        if meter = Meter.find_by(mpan_mprn: mpxn)
          add_attribute_to_meter(meter, attrs.keys[0], attrs.values[0], user)
        else
          raise StandardError, "No meter found for #{mpxn}"
        end
      end

      aggregated_gas.each do |urn, attrs|
        puts urn.to_s
        if school = School.find_by(urn: urn)
          add_attribute_to_school(school, attrs.keys[0], attrs.values[0], ['aggregated_gas'], user)
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
        puts mpxn.to_s
        if meter = Meter.find_by(mpan_mprn: mpxn)
          remove_attribute_from_meter(meter, attrs.keys[0])
        else
          raise StandardError, "No meter found for #{mpxn}"
        end
      end

      aggregated_gas.each do |urn, attrs|
        puts urn.to_s
        if school = School.find_by(urn: urn)
          remove_attribute_from_school(school, attrs.keys[0])
        else
          raise StandardError, "No school found for #{urn}"
        end
      end
    end
  end
end

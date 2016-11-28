namespace :merit do
  desc 'Award badges/points for fall in weekly energy usage.'
  task weekly_energy_reduction: [:environment] do
    ::School.find_each do |school|
      if school.weekly_energy_reduction?
        school.add_badge(9) unless school.has_badge?(9) # Only award badge once
        school.add_points(10)
      end
    end
  end

  desc 'Award badges/points for a percentage drop electricity usage.'
  task electricity_reduction: [:environment] do
    ::School.find_each do |school|
      case school.electricity_reduction
      when 0.1..0.2
        unless school.has_badge?(10)
          school.add_badge(10)
          school.add_points(50)
        end
      when 0.2..1
        unless school.has_badge?(11)
          school.add_badge(11)
          school.add_points(100)
        end
      end
    end
  end

  desc 'Award badges/points for a percentage drop gas usage.'
  task gas_reduction: [:environment] do
    ::School.find_each do |school|
      case school.gas_reduction
      when 0.1..0.2
        unless school.has_badge?(12)
          school.add_badge(12)
          school.add_points(50)
        end
      when 0.2..1
        unless school.has_badge?(13)
          school.add_badge(13)
          school.add_points(100)
        end
      end
    end
  end

  desc 'Award points/badges for recording an activity per week all term.'
  task activity_per_week: [:environment] do
    ::School.find_each do |school|
      next if school.has_badge?(8) # Only award badge/points once per term
      if school.activity_per_week?
        school.add_badge(8)
        school.add_points(50)
      end
    end
  end
end

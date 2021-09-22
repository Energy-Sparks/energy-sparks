FactoryBot.define do
  factory :fuel_progress, class: Targets::FuelProgress do
    transient do
      fuel_type  { :electricity }
      progress   { -0.5 }
      usage      { 100 }
      target     { 200 }
      recent_data { true }
    end

    initialize_with{ new(fuel_type: fuel_type, progress: progress, usage: usage, target: target, recent_data: recent_data) }
  end
end

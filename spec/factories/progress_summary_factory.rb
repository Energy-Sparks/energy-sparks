FactoryBot.define do
  factory :progress_summary, class: Targets::ProgressSummary do
    transient do
      school_target   { create(:school_target) }
      electricity     { build(:fuel_progress) }
      gas             { build(:fuel_progress, fuel_type: :gas) }
      storage_heater  { build(:fuel_progress, fuel_type: :storage_heater) }
    end
    initialize_with{ new(school_target: school_target, electricity: electricity, gas: gas, storage_heater: storage_heater) }
  end

  factory :progress_summary_with_failed_target, class: Targets::ProgressSummary do
    transient do
      school_target   { create(:school_target) }
      electricity     { build(:fuel_progress) }
      gas             { build(:fuel_progress, fuel_type: :gas, progress: 0.5) }
      storage_heater  { build(:fuel_progress, fuel_type: :storage_heater) }
    end
    initialize_with{ new(school_target: school_target, electricity: electricity, gas: gas, storage_heater: storage_heater) }
  end
end

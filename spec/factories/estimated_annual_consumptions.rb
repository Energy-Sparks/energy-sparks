FactoryBot.define do
  factory :estimated_annual_consumption do
    year { 1 }
    electricity { 1.5 }
    storage_heaters { 1.5 }
    gas { 1.5 }
    school factory: :school
  end
end

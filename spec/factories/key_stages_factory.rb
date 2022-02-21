FactoryBot.define do
  factory :key_stage do
    sequence(:name)   {|n| "KeyStage #{n}"}
  end
end


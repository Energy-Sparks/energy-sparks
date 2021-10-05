FactoryBot.define do
  factory :cad do
    sequence(:name)   {|n| "CAD #{n}"}
    device_identifier       { SecureRandom.uuid }
  end
end


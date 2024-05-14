FactoryBot.define do
  factory :dashboard_message do
    message { 'MyText' }
    messageable { create(:school_group) }
  end
end

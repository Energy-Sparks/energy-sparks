FactoryBot.define do
  factory :alert_type_rating_unsubscription do
    alert_type_rating
    contact
    scope { :email }
    reason { 'Not interested' }
    unsubscription_period { :forever }
  end
end

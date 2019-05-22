
FactoryBot.define do
  factory :alert_type_rating_unsubscription do
    alert_type_rating
    contact
    scope { :email }
  end
end

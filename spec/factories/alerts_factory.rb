FactoryBot.define do
  factory :alert do
    alert_type
    school
    status      { :good }
    data        { {} }
    run_on      { Date.today }
    summary     { 'All good today' }
  end
end

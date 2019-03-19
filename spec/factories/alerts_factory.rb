FactoryBot.define do
  factory :alert do
    transient do
      rating { 5.0 }
    end
    alert_type
    run_on { Date.today }
    sequence(:summary) {|n| "Alert #{n}"}
    data {{
      'help_url'  => 'https://example.com',
      'detail'    => [{ 'type' => '', 'content' => 'ImportantContent' }],
      'rating' => rating
    }}
  end
end

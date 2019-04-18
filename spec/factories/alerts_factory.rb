FactoryBot.define do
  factory :alert do
    transient do
      rating { 5.0 }
      template_data { {} }
    end
    alert_type
    run_on { Date.today }
    sequence(:summary) {|n| "Alert #{n}"}
    data {{
      'help_url'  => 'https://example.com',
      'detail'    => [{ 'type' => '', 'content' => 'ImportantContent' }],
      'rating' => rating,
      'template_data' => template_data
    }}
  end
end

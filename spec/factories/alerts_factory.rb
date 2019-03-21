FactoryBot.define do
  factory :alert do
    alert_type
    run_on { Date.today }
    sequence(:summary) {|n| "Alert #{n}"}
    data {{
      'help_url'  => 'https://example.com',
      'detail'    => [{ 'type' => '', 'content' => 'ImportantContent' }]
    }}
  end
end
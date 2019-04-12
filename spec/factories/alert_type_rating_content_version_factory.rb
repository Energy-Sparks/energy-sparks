FactoryBot.define do
  factory :alert_type_rating_content_version do
    alert_type_rating
    pupil_dashboard_title {'a thing has happened'}
    teacher_dashboard_title {'a thing has happened'}
    page_title {'A thing has happened' }
    page_content {'A thing has happened and you should do something about it' }
  end
end

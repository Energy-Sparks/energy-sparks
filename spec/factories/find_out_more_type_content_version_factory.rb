FactoryBot.define do
  factory :find_out_more_type_content_version do
    find_out_more_type
    pupil_dashboard_title {'a thing has happened'}
    teacher_dashboard_title {'a thing has happened'}
    page_title {'A thing has happened' }
    page_content {'A thing has happened and you should do something about it' }
  end
end

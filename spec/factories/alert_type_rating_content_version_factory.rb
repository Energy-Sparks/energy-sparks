FactoryBot.define do
  factory :alert_type_rating_content_version do
    alert_type_rating
    pupil_dashboard_title {'a thing has happened'}
    management_dashboard_title {'a thing has happened'}
    management_priorities_title {'a thing has happened'}
    find_out_more_title {'A thing has happened' }
    find_out_more_content {'A thing has happened and you should do something about it' }
    sms_content {'A thing has happened' }
    email_title {'A thing has happened and you should do something about it' }
    email_content {'A thing has happened and you should do something about it' }
    group_dashboard_title { 'a thing has happened in this group' }
  end
end

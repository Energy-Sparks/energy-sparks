FactoryBot.define do
  factory :school_grouping do
    school
    school_group { create(:school_group, group_type: :multi_academy_trust) }
    role { 'organisation' }
  end
end

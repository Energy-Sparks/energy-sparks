FactoryGirl.define do
  factory :score_point, class: Merit::Score::Point do
    sequence(:num_points, 10)
    score
  end
end

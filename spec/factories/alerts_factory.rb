FactoryBot.define do
  factory :alert do
    school
    alert_type
    run_on { Time.zone.today }
    rating { 5.0 }
    priority_data do
      { 'time_of_year_relevance' => 5.0 }
    end

    initialize_with do
      type_class = Object.const_get(alert_type.class_name) if attributes.key?(:variables)
      if type_class.respond_to?(:template_variables)
        available_names = type_class.template_variables.values.map(&:keys).flatten.map do |key|
          key.to_s.gsub('£', 'gbp').to_sym
        end
        variables.each_key do |name|
          raise ArgumentError, "Variable #{name} not in #{available_names}" unless available_names.include?(name.to_sym)
        end
      end
      new(**attributes)
    end

    trait :with_run do
      alert_generation_run { FactoryBot.build(:alert_generation_run, school: school) }
    end
  end
end

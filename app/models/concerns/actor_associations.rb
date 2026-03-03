module ActorAssociations
  extend ActiveSupport::Concern

  class_methods do
    def actor_associations_for(model_action_map)
      model_action_map.each do |model_name, actions|
        assoc_prefix = model_name.to_s.gsub('::', '_').underscore.pluralize

        Array(actions).each do |action|
          has_many :"#{assoc_prefix}_#{action}",
                   class_name: model_name.to_s,
                   inverse_of: :"#{action}_by",
                   foreign_key: :"#{action}_by_id",
                   dependent: :nullify
        end
      end
    end
  end
end

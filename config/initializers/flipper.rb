Flipper.register(:admins) do |actor, context|
  actor.respond_to?(:admin?) && actor.admin?
end

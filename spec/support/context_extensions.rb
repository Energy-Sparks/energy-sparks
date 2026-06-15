module ContextExtensions
  # toggle_feature: Run context twice, once with feature switched on,
  # and once with it switched off. Example usage:
  #
  # context 'when recording an activity', toggle_feature: :todos
  # context toggle_feature: :todos
  #
  # feature: Run context once with feature switched on
  #
  # context 'when recording an activity', with_feature: :todos
  # context with_feature: :todos
  # context without_feature: :todos
  #
  def context(description = nil, *, with_feature: nil, without_feature: nil, toggle_feature: nil, **metadata,
              &)
    description = "#{description} " if description
    if (name = toggle_feature || with_feature || without_feature)
      if toggle_feature || with_feature
        super("#{description}with #{name} feature switched on", *, **metadata) do
          before { Flipper.enable(name) }

          instance_eval(&)

          after { Flipper.disable(name) }
        end
      end

      if toggle_feature || without_feature
        super("#{description}with #{name} feature switched off", *, **metadata) do
          before { Flipper.disable(name) }

          instance_eval(&)
        end
      end
    else
      super(description, *, **metadata, &)
    end
  end
end

RSpec::Core::ExampleGroup.singleton_class.prepend(ContextExtensions)

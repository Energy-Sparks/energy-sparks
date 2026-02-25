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
  def context(description = nil, *args, with_feature: nil, without_feature: nil, toggle_feature: nil, **metadata, &block)
    description = "#{description} " if description
    if (name = toggle_feature || with_feature || without_feature)
      if toggle_feature || with_feature
        super("#{description}with #{name} feature switched on", *args, **metadata) do
          before { Flipper.enable(name) }

          instance_eval(&block)

          after { Flipper.disable(name) }
        end
      end

      if toggle_feature || without_feature
        super("#{description}with #{name} feature switched off", *args, **metadata) do
          before { Flipper.disable(name) }

          instance_eval(&block)
        end
      end
    else
      super(description, *args, **metadata, &block)
    end
  end
end

RSpec::Core::ExampleGroup.singleton_class.prepend(ContextExtensions)

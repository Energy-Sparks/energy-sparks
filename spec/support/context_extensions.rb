module ContextExtensions
  def context(description, *args, toggle_feature: nil, **metadata, &block)
    if toggle_feature
      super("#{description} with #{toggle_feature} feature switched on", *args, **metadata) do
        before { Flipper.enable(toggle_feature) }

        instance_eval(&block)
        after { Flipper.disable(toggle_feature) }
      end

      super("#{description} with #{toggle_feature} feature switched off", *args, **metadata) do
        before { Flipper.disable(toggle_feature) }

        instance_eval(&block)
      end
    else
      super(description, *args, **metadata, &block)
    end
  end
end

RSpec::Core::ExampleGroup.singleton_class.prepend(ContextExtensions)

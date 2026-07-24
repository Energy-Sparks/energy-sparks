module Admin
  class HeaderNavComponent < ApplicationComponent
    renders_one :header, lambda { |**kwargs|
      Elements::HeaderComponent.new(level: 1, **kwargs)
    }
    renders_many :buttons, lambda { |*args, **kwargs|
      Elements::ButtonComponent.new(*args, size: :sm, **merge_classes('', kwargs))
    }

    def initialize(*_args, **_kwargs)
      super
    end
  end
end

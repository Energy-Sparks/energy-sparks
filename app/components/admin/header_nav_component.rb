module Admin
  class HeaderNavComponent < ApplicationComponent
    renders_one :header, ->(**kwargs) do
      Elements::HeaderComponent.new(**{ level: 1 }.merge(kwargs))
    end
    renders_many :buttons, ->(*args, **kwargs) do
      Elements::ButtonComponent.new(*args, **merge_classes('', kwargs))
    end

    def initialize(*_args, **_kwargs)
      super
    end
  end
end

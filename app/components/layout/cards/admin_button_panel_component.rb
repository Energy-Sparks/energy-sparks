module Layout
  module Cards
    class AdminButtonPanelComponent < LayoutComponent
      renders_one :status, ->(*args, **kwargs) do
        Elements::BadgeComponent.new(*args, **merge_classes('p-2', kwargs))
      end
      renders_many :buttons, ->(*args, **kwargs) do
        Elements::ButtonComponent.new(*args, **kwargs.merge(size: :sm))
      end

      def initialize(current_user:, row: false, highlight: true, **_kwargs)
        super
        @current_user = current_user
        @row = row
        @highlight = highlight
        add_classes('p-2 bg-grey-pale') if @highlight
        add_classes('row') if @row
      end

      def render?
        @current_user&.admin?
      end
    end
  end
end

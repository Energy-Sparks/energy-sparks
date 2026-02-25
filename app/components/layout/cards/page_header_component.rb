module Layout
  module Cards
    class PageHeaderComponent < LayoutComponent
      renders_one :callout, ->(title:, **kwargs) do
        CalloutComponent.new(title:, **merge_classes('px-3 py-2 rounded', kwargs))
      end

      def initialize(title:, subtitle: nil, theme: :white, **_kwargs)
        super
        @title = title
        @subtitle = subtitle
      end

      class CalloutComponent < LayoutComponent
        renders_many :rows

        def initialize(title: nil, classes: nil, theme: :white, **_kwargs)
          super
          @title = title
        end

        erb_template <<-ERB
          <%= tag.div id: id, class: classes do %>
            <% if @title %>
              <div class="row">
                <div class="col">
                  <h4 class="pt-0"><%= @title %></h4>
                </div>
              </div>
            <% end %>
            <% rows.each do |row| %>
              <div class="row">
                <div class="col">
                  <%= row %>
                </div>
              </div>
            <% end %>
          <% end %>
        ERB
      end
    end
  end
end

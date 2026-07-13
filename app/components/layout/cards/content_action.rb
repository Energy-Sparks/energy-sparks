# frozen_string_literal: true

module Layout
  module Cards
    class ContentAction < LayoutComponent # rubocop:disable ViewComponent/PreferComposition
      renders_one :body
      renders_one :action
    end
  end
end

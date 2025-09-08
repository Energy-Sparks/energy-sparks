module Layout
  module Cards
    class AdminButtonPanelComponentPreview < ViewComponent::Preview
      def default
        render(Layout::Cards::AdminButtonPanelComponent.new(current_user: User.admin.first)) do |panel|
          panel.with_button 'Success', '/', style: :success
          panel.with_button 'Danger', '/', style: :danger
        end
      end

      def row
        render(Layout::Cards::AdminButtonPanelComponent.new(current_user: User.admin.first,
                                                            row: true,
                                                            highlight: false)) do |panel|
          panel.with_button 'Success', '/', style: :success
          panel.with_button 'Danger', '/', style: :danger
        end
      end

      def with_status
        render(Layout::Cards::AdminButtonPanelComponent.new(current_user: User.admin.first)) do |panel|
          panel.with_status 'Warning', style: :warning
          panel.with_button 'Success', '/', style: :success
          panel.with_button 'Danger', '/', style: :danger
        end
      end
    end
  end
end

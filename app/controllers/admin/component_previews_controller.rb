module Admin
  class ComponentPreviewsController < AdminController
    include ViewComponent::PreviewActions

    def index
      @previews = ViewComponent::Preview.all.sort_by(&:name)
      @page_title = 'Component Previews'
      render 'view_components/index', **determine_layout
    end
  end
end

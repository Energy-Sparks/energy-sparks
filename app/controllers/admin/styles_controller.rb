module Admin
  class StylesController < AdminController
    before_action :bootstrap_5

    def bootstrap_5
      @bootstrap_version = 5
    end
  end
end

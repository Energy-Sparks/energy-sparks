# frozen_string_literal: true

module Admin
  class AdminCrudController < AdminController
    load_and_authorize_resource instance_name: :resource

    def new; end

    def edit; end

    def create
      if @resource.save
        redirect_to polymorphic_path([:admin, self.class::MODEL]),
                    notice: "New #{self.class::MODEL.model_name.human} created."
      else
        render :new
      end
    end

    def update
      if @resource.update(resource_params)
        redirect_to polymorphic_path([:admin, self.class::MODEL]),
                    notice: "#{self.class::MODEL.model_name.human} was updated."
      else
        render :edit
      end
    end

    private

    def resource_params
      fields = self.class::MODEL.column_names.map(&:to_sym) - %i[id created_at updated_at]
      params.require(self.class::MODEL.name.underscore.to_sym).permit(*fields)
    end
  end
end

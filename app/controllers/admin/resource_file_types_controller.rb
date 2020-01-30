module Admin
  class ResourceFileTypesController < AdminController
    load_and_authorize_resource

    def index
      @resource_file_types = @resource_file_types.order(:position)
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @resource_file_type.save
        redirect_to admin_resource_file_types_path, notice: 'Resource type was successfully created.'
      else
        render :new
      end
    end

    def update
      if @resource_file_type.update(resource_file_type_params)
        redirect_to admin_resource_file_types_path, notice: 'Resource type was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @resource_file_type.destroy
      redirect_to admin_resource_file_types_path, notice: 'Resource type was successfully destroyed.'
    end

    private

    def resource_file_type_params
      params.require(:resource_file_type).permit(:title, :position)
    end
  end
end

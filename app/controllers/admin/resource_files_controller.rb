module Admin
  class ResourceFilesController < AdminController
    load_and_authorize_resource

    def index
      @resource_files = ResourceFile.order(:title)
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @resource_file.save
        redirect_to admin_resource_files_path, notice: 'Resource was successfully created.'
      else
        render :new
      end
    end

    def update
      if @resource_file.update(resource_file_params)
        redirect_to admin_resource_files_path, notice: 'Resource was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @resource_file.destroy
      redirect_to admin_resource_files_path, notice: 'Resource was successfully destroyed.'
    end

    private

    def resource_file_params
      params.require(:resource_file).permit(:title, :description, :file, :resource_file_type_id)
    end
  end
end

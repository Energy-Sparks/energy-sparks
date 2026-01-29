module Admin
  class FundersController < AdminController
    load_and_authorize_resource

    def index
      @funders = Funder.all.order(name: :asc)
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @funder.save
        redirect_to(admin_funders_path, notice: 'Funder was successfully created')
      else
        render :new
      end
    end

    def update
      if @funder.update(funder_params)
        redirect_to(admin_funders_path, notice: 'Funder was successfully updated.')
      else
        render :edit
      end
    end

    def destroy
      if @funder.destroy
        redirect_to(admin_funders_path, alert: 'Funder was successfully deleted.')
      else
        redirect_to(admin_funders_path, alert: @funder.errors.full_messages.to_sentence)
      end
    end

    private

    def funder_params
      params.require(:funder).permit(:name)
    end
  end
end

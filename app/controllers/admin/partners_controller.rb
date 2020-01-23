module Admin
  class PartnersController < AdminController
    load_and_authorize_resource

    def index
      @partners = Partner.order(:position)
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @partner.save
        redirect_to admin_partners_path, notice: 'Partner was successfully created.'
      else
        render :new
      end
    end

    def update
      if @partner.update(partner_params)
        redirect_to admin_partners_path, notice: 'Partner was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @partner.destroy
      redirect_to admin_partners_path, notice: 'Partner was successfully destroyed.'
    end

    private

    def partner_params
      params.require(:partner).permit(:position, :image)
    end
  end
end

module Admin
  class TestimonialsController < AdminController
    include LocaleHelper
    include ImageResizer

    include ActiveStorage::SetCurrent

    before_action :load_testimonials, only: [:index, :show]
    before_action only: [:create, :update] do
      resize_image(testimonial_params[:image])
    end

    load_and_authorize_resource

    def index
    end

    def show
      render :index
    end

    def create
      if @testimonial.save
        redirect_to admin_testimonial_path(@testimonial), notice: 'Testimonial was successfully created.'
      else
        render :new
      end
    end

    def update
      if @testimonial.update(testimonial_params)
        redirect_to admin_testimonial_path(@testimonial), notice: 'Testimonial was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @testimonial.destroy
      redirect_to admin_testimonials_path, notice: 'Testimonial was successfully deleted.'
    end

    private

    def load_testimonials
      @testimonials = Testimonial.all
    end

    def testimonial_params
      translated_params = t_params(Testimonial.mobility_attributes)
      params.require(:testimonial).permit(translated_params, :image, :name, :organisation, :category, :active, :case_study_id)
    end
  end
end

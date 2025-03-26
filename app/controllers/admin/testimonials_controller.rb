module Admin
  class TestimonialsController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    def show
    end

    def create
      if @testimonial.save
        redirect_to admin_testimonials_path, notice: 'Testimonial was successfully created.'
      else
        render :new
      end
    end

    def update
      if @testimonial.update(testimonial_params)
        redirect_to admin_testimonials_path, notice: 'Testimonial was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @testimonial.destroy
      redirect_to admin_testimonials_path, notice: 'Testimonial was successfully deleted.'
    end

    private

    def testimonial_params
      translated_params = t_params(Testimonial.mobility_attributes)
      params.require(:testimonial).permit(translated_params, :image, :name, :organisation, :category, :active, :case_study_id)
    end
  end
end

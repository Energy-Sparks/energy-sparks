module Admin::Comparisons
  class FootnotesController < AdminController
    include LocaleHelper

    load_and_authorize_resource :footnote, class: 'Comparison::Footnote'

    def index
    end

    def create
      if @footnote.save
        redirect_to admin_comparisons_footnotes_path, notice: 'Footnote was successfully created.'
      else
        render :new
      end
    end

    def update
      if @footnote.update(footnote_params)
        redirect_to admin_comparisons_footnotes_path, notice: 'Footnote was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @footnote.destroy
      redirect_to admin_comparisons_footnotes_path, notice: 'Footnote was successfully deleted.'
    end

    private

    def footnote_params
      translated_params = t_params(Comparison::Footnote.mobility_attributes)
      params.require(:footnote).permit(translated_params, :key)
    end
  end
end

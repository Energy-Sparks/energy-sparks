module Admin
  class EquivalenceTypesController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    before_action :set_template_variables, except: %i[index show]

    def index
      @equivalence_types = @equivalence_types.order(created_at: :desc)
    end

    def new
      @content = EquivalenceTypeContentVersion.new
    end

    def create
      @content = @equivalence_type.content_versions.new(content_params[:content])
      if @equivalence_type.update_with_content!(equivalence_type_params, @content)
        redirect_to admin_equivalence_types_path(@equivalence_type), notice: 'Equivalence created'
      else
        render :new
      end
    end

    def edit
      @content = @equivalence_type.current_content
    end

    def update
      @content = @equivalence_type.content_versions.new(content_params[:content])
      if @equivalence_type.update_with_content!(equivalence_type_params, @content)
        redirect_to admin_equivalence_types_path, notice: 'Equivalence type updated'
      else
        render :edit
      end
    end

    def destroy
      @equivalence_type.destroy
      redirect_to admin_equivalence_types_path, notice: 'Equivalence type was successfully deleted.'
    end

    private

    def equivalence_type_params
      params.require(:equivalence_type).permit(:meter_type, :time_period, :image_name)
    end

    def content_params
      translated_params = t_params(EquivalenceTypeContentVersion.mobility_attributes)
      params.require(:equivalence_type).permit(
        content: translated_params
      )
    end

    def set_template_variables
      @template_variables = EnergyConversions.front_end_conversion_list.deep_transform_keys do |key|
        :"#{key.to_s.gsub('£', 'gbp')}"
      end
    end
  end
end

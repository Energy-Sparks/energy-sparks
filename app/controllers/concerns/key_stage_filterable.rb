module KeyStageFilterable
  extend ActiveSupport::Concern

private

  def key_stage_filter_params
    params.permit(key_stage_tag: { key_stage_names: [] })
  end

  def work_out_which_filters_to_set
    key_stage_tag = key_stage_filter_params[:key_stage_tag]

    if key_stage_tag.nil?
      default_filters
    else
      filters = key_stage_tag[:key_stage_names]
      filters.delete("")
      filters
    end
  end

  def default_filters
    if current_user.nil? || current_user.school.nil?
      # TODO remove this hardcoding
      %w(KS1 KS2 KS3)
    else
      # Set for the school defaults
      current_user.school.key_stage_list
    end
  end
end

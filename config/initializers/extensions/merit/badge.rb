Rails.logger.info "Loading extensions to Merit::Badge from #{ __FILE__ }"
Merit::Badge.class_eval do
  def image
    custom_fields[:image] || 'badges/default.png'
  end
end

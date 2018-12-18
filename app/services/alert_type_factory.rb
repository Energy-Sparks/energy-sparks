class AlertTypeFactory
  def initialize(alert_hash)
    @alert_hash = alert_hash
  end

  def create
    @alert_hash.each do |alert|
      next if alert[:title].nil?

      fuel_type   = alert[:fuel_type].parameterize.underscore.to_sym unless alert[:fuel_type].nil?
      subcategory = alert[:sub_category].parameterize.underscore.to_sym unless alert[:sub_category].nil?
      frequency   = alert[:frequency].parameterize.underscore.to_sym

      AlertType.where(title: alert[:title], fuel_type: fuel_type, sub_category: subcategory, analysis: alert[:analysis], description: alert[:description], frequency: frequency).first_or_create
    end
  end
end

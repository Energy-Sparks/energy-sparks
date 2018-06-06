class AlertTypeFactory
  def initialize(alert_hash)
    @alert_hash = alert_hash
  end

  def create
    @alert_hash.each do |alert|
      next if alert[:title].nil?
      category    = alert[:category].parameterize.underscore.to_sym unless alert[:category].nil?
      subcategory = alert[:sub_category].parameterize.underscore.to_sym unless alert[:sub_category].nil?
      frequency   = alert[:frequency].parameterize.underscore.to_sym

      AlertType.where(title: alert[:title], category: category, sub_category: subcategory, analysis: alert[:analysis], description: alert[:description], frequency: frequency).first_or_create
    end
  end
end

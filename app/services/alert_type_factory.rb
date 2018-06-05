class AlertTypeFactory
  def initialize(alert_hash)
    @alert_hash = alert_hash
  end

  def create
    @alert_hash.each do |alert|
      next if alert[:category].nil?
      category = alert[:category].parameterize.underscore.to_sym
      subcategory = alert[:subcategory].parameterize.underscore.to_sym
      long_term = alert[:term] == 'Long'
      daily_frequency = alert[:frequency].to_i

      al = AlertType.where(title: alert[:alert], category: category, sub_category: subcategory, long_term: long_term, analysis_description: alert[:analysis], sample_message: alert[:sample_message], daily_frequency: daily_frequency).first_or_create
      pp al
    end
  end
end

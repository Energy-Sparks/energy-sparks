module TransifexSerialisable
  # rubocop:disable Style/RegexpLiteral
  extend ActiveSupport::Concern

  TRIX_DIV = "<div class=\"trix-content\">".freeze
  CLOSE_DIV = "</div>".freeze

  def self.included(base)
    base.include ClassMethods
  end

  #Convert object to a hash structure suitable for dumping to
  #a Rails style YAML file for sending to TX
  #
  #To customise the mapping, add a TX_ATTRIBUTE_MAPPING const to the
  #including class. This should be a hash of the attribute names to
  #a hash of options.
  #
  # templated will control whether the value has Mustache templates converted
  # to YAML templates
  #
  # html is used to indicate that an otherwise simple attribute on the model
  # should be given a key name with an "_html" suffix.
  #
  #E.g.
  # { attribute_name: {templated: true, html: true} }
  def tx_serialise
    attribs = {}
    self.class.mobility_attributes.map.each do |attr|
      if tx_valid_attribute(attr)
        attr_key = tx_attribute_key(attr)
        attribs[attr_key] = tx_value(attr)
      end
    end
    data = { resource_key => attribs }
    return { "en" => data }
  end

  # overide in classes to check instance-specific fields
  def tx_valid_attribute(_attr)
    true
  end

  #Update the model using data from transifex
  def tx_update(data, locale)
    raise "Unexpected locale" unless I18n.available_locales.include?(locale)
    raise "Unexpected i18n format" unless data[locale.to_s].present? && !data[locale.to_s][resource_key].nil?

    translated_attributes = self.class.mobility_attributes.map { |attr| tx_attribute_key(attr) }
    to_update = {}
    tx_attributes = data[locale.to_s][resource_key]
    tx_attributes.each_key do |attr|
      #ignore any attributes that aren't translated
      if translated_attributes.include?(attr)
        #map translation key to translated attribute name
        name = tx_key_to_attribute_name(attr, locale)
        #get value, converting template formats if required
        value = tx_to_attribute_value(attr, tx_attributes)
        #rewrite links
        value = rewrite_links_in_value(value) if self.class.tx_rewrite_links?(name.to_sym)
        #add to hash for updating
        to_update[name] = value
      end
    end
    self.update!(to_update)
  end

  def tx_name
    "#{self.class.model_name.human} #{self.id}"
  end

  def tx_slug
    resource_key
  end

  def tx_categories
    [self.class.model_name.i18n_key.to_s]
  end

  def tx_status
    TransifexStatus.find_by_model(self)
  end

  def tx_key_to_attribute_name(attr, locale)
    "#{original_attribute_key(attr)}_#{locale}".to_sym
  end

  def tx_to_attribute_value(attr, tx_attributes)
    if self.class.tx_templated_attribute?(original_attribute_key(attr))
      yaml_template_to_mustache(tx_attributes[attr])
    else
      tx_attributes[attr]
    end
  end

  def tx_attribute_key(attr)
    self.class.tx_html_field?(attr) ? "#{attr}_html" : attr
  end

  def original_attribute_key(attr)
    attr.chomp('_html')
  end

  def tx_value(attr)
    #TODO is there a better way to access the HTML?
    if self.class.tx_rich_text_field?(attr)
      value = send(attr).to_s
      value = remove_newlines(value)
      value = remove_rich_text_wrapper(value)
    else
      value = self.send("#{attr}_#{I18n.default_locale}".to_sym)
    end
    if self.class.tx_templated_attribute?(attr)
      value = mustache_to_yaml(value)
    end
    value ? value.strip : value
  end

  def resource_key
    "#{self.class.model_name.i18n_key}_#{self.id}"
  end

  def yaml_template_to_mustache(value)
    value = value.gsub(/%{tx_chart_([a-z0-9_|£]+)}/, '{{#chart}}\1{{/chart}}')
    value = value.gsub(/%{tx_var_([a-z0-9_|£]+)}/, '{{\1}}')
    # retain this conversion for legacy content which didn't have the tx_chart_ prefix
    value = value.gsub(/%{([a-z0-9_|£]+)}/, '{{#chart}}\1{{/chart}}')
    value
  end

  #we only have a single custom Mustache tag, see SchoolTemplate
  #we will need to do something more sophisticated if we add more
  def mustache_to_yaml(value)
    value = value.gsub(/{{#chart}}([a-z0-9_|£]+){{\/chart}}/, '%{tx_chart_\1}')
    value = value.gsub(/{{([a-z0-9_|£]+)}}/, '%{tx_var_\1}')
    value
  end

  def rewrite_links_in_value(value)
    link_rewrites.each do |rewrite|
      value.gsub!(rewrite.escaped_source, rewrite.target)
    end
    value
  end

  def rewrite_all
    rewritten = {}
    self.class.tx_rewriteable_fields.each do |attr|
      value = send(attr).to_s.dup
      value = remove_newlines(value)
      value = remove_rich_text_wrapper(value)
      rewritten[attr] = rewrite_links_in_value(value)
    end
    rewritten
  end

  def has_content?
    tx_serialise["en"][resource_key].values.any?(&:present?)
  end

  private

  def remove_newlines(value)
    value.delete("\n")
  end

  def remove_rich_text_wrapper(value)
    value.start_with?(TRIX_DIV) ? value.gsub(TRIX_DIV, '').chomp(CLOSE_DIV) : value
  end

  module ClassMethods
    def tx_rewriteable_fields
      return [] unless const_defined?(:TX_REWRITEABLE_FIELDS)
      const_get(:TX_REWRITEABLE_FIELDS)
    end

    def tx_attribute_mapping(attr)
      return {} unless const_defined?(:TX_ATTRIBUTE_MAPPING)
      const_get(:TX_ATTRIBUTE_MAPPING).key?(attr.to_sym) ? const_get(:TX_ATTRIBUTE_MAPPING)[attr.to_sym] : {}
    end

    def tx_html_field?(attr)
      tx_rich_text_field?(attr) || tx_html_attribute?(attr)
    end

    def tx_html_attribute?(attr)
      mapping = tx_attribute_mapping(attr)
      return mapping.key?(:html) && mapping[:html]
    end

    def tx_rewrite_links?(attr)
      return tx_model_has_link_rewrites? && tx_rewriteable_fields.include?(attr)
    end

    def tx_templated_attribute?(attr)
      mapping = tx_attribute_mapping(attr)
      return mapping.key?(:templated) && mapping[:templated]
    end

    #borrowed from: https://github.com/rails/rails/blob/3872bc0e54d32e8bf3a6299b0bfe173d94b072fc/actiontext/lib/action_text/attribute.rb#L61
    def tx_rich_text_field?(name)
      reflect_on_all_associations(:has_one).collect(&:name).include?("rich_text_#{name}".to_sym)
    end

    def tx_model_has_link_rewrites?
      reflect_on_all_associations(:has_many).collect(&:name).include?(:link_rewrites)
    end

    def tx_resources
      all.order(:id)
    end
  end
  # rubocop:enable Style/RegexpLiteral
end

module TransifexSerialisable
  extend ActiveSupport::Concern

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
    self.class.mobility_attributes.map(&:to_sym).each do |attr|
      attr_key = tx_attribute_key(attr)
      attribs[attr_key] = tx_value(attr)
    end
    data = { resource_key => attribs }
    return { en: data }
  end

  #Update the model using data from transifex
  def tx_update(data, locale)
    #loop through translatable attributes locally
    #get data from transifex, using locale as key
    #map _html to bare key name
    #translate templated fields back
    #do a single model update
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

  def tx_attribute_key(attr)
    self.class.tx_html_field?(attr) ? "#{attr}_html".to_sym : attr
  end

  def tx_value(attr)
    #TODO is there a better way to access the HTML?
    value = self.class.tx_rich_text_field?(attr) ? send(attr).to_s : self[attr]
    #TODO need to change content to handle substitutions
    self.class.tx_templated_attribute?(attr) ? mustache_to_yaml(value) : value
  end

  def resource_key
    "#{self.class.model_name.i18n_key}_#{self.id}".to_sym
  end

  private

  def mustache_to_yaml(value)
    value.gsub(/{{/, "%{").gsub(/}}/, "}")
  end

  module ClassMethods
    def tx_attribute_mapping(attr)
      return {} unless const_defined?(:TX_ATTRIBUTE_MAPPING)
      const_get(:TX_ATTRIBUTE_MAPPING).key?(attr) ? const_get(:TX_ATTRIBUTE_MAPPING)[attr] : {}
    end

    def tx_html_field?(attr)
      tx_rich_text_field?(attr) || tx_html_attribute?(attr)
    end

    def tx_html_attribute?(attr)
      mapping = tx_attribute_mapping(attr)
      return mapping.key?(:html) && mapping[:html]
    end

    def tx_templated_attribute?(attr)
      mapping = tx_attribute_mapping(attr)
      return mapping.key?(:templated) && mapping[:templated]
    end

    #borrowed from: https://github.com/rails/rails/blob/3872bc0e54d32e8bf3a6299b0bfe173d94b072fc/actiontext/lib/action_text/attribute.rb#L61
    def tx_rich_text_field?(name)
      reflect_on_all_associations(:has_one).collect(&:name).include?("rich_text_#{name}".to_sym)
    end
  end
end

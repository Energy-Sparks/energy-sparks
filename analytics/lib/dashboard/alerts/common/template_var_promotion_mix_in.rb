# to reduce class clutter
# TODO(PH 10Oct2020) needs further work as @attributes doesn't work as mixin only if as a class
module TemplateVarPromotionMixIn
  def self.execute_variables(template_variables)
    template_variables.select{ |var, val| val.key?(:calc)}.each do |var, val|
      if instance_variable_get("@#{var}").nil?
        d = instance_exec(&val[:calc])
        instance_variable_set("@#{var}", d)
      end
    end
  end

  def self.attr_reader(*vars)
    @attributes ||= []
    @attributes.concat vars
    super(*vars)
  end

  def self.attributes
    @attributes
  end

  def attributes
    self.class.attributes
  end

  def set_template_variables_as_attr_reader(vars)
    vars.keys.each do |var|
      self.class.send(:attr_reader, var) if !check || attributes.nil? || !attributes.include?(var)
    end
  end

  def set_template_variables(vars)
    vars.each do |name, value|
      new_template_variable(name, value)
    end
  end

  def new_template_variable(name, value)
    self.class.send(:attr_reader, name)
    instance_variable_set("@#{name}", value)
  end
end

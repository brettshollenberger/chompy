class ROpenStruct
  def initialize(options={})
    options.each do |key, value|
      if value.is_a?(Hash)
        value = ROpenStruct.new(value)
      end

      send("#{key}=", value)
    end
  end

  def as_json
    attributes
  end

  def attributes
    instance_variables.reduce({}) do |attrs, key|
      key        = key[1..-1]
      value      = send(key)

      if value.is_a?(ROpenStruct)
        value = value.attributes
      end

      attrs[key] = value
      attrs
    end
  end

private
  def respond_to_missing?(method_name, include_private=false)
    method_name.to_s.include?("=") || super
  end

  def eigenclass
    class << self
      self
    end
  end

  def method_missing(method_name, *args, &block)
    if method_name.to_s.include?("=")
      method_name = method_name.to_s.gsub(/\=/) {}

      eigenclass.send :define_method, method_name do
        instance_variable_get("@#{method_name}")
      end

      eigenclass.send :define_method, "#{method_name}=" do |value|
        instance_variable_set("@#{method_name}", value)
      end

      send("#{method_name}=", *args, &block)
    else
      super
    end
  end
end

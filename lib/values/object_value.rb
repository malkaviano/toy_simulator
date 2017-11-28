module SnED100
  class ObjectValue
    def initialize(values)
      values.each do |key, value|
        instance_variable_set("@#{key.to_s}", value)

        self.class.send(:define_method, key) { instance_variable_get("@#{key.to_s}") if self.respond_to? key }
      end
    end

    def method_missing(m, *params, &block)
      nil
    end
  end
end

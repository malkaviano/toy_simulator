module SnED100
  class Effect < ObjectValue
    def initialize(values)
      func = values[:func]

      values[:func] = lambda do |arg|
        Integer(func.call(arg))
      end

      super
    end
  end
end

require_relative 'object_value'

module SnED100
  class Gain < ObjectValue
    def initialize(amount)
      super :amount => amount
    end
  end
end

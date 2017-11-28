require_relative 'object_value'

module SnED100
  class Damage < ObjectValue
    def initialize(amount)
      super :amount => -amount
    end
  end
end

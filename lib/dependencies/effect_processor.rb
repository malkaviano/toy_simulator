module SnED100
  class EffectProcessor
    @@effect_tracker = Struct.new("EffectTracker", :name, :remaining, :cumulative)

    def initialize(values)
      @enums = values[:enums]
      @errors = values[:errors]
      @effect_repository = values[:effect_repository]

      raise "ErrorCodes is required" if @errors.nil?
      raise @errors::REQUIRED_ENUMS if @enums.nil?
      raise @errors::REQUIRED_EFFECT_REPOSITORY if @effect_repository.nil?
    end

    def effect_tracker(name)
      effect = find_effect(name)

      @@effect_tracker.new(effect.name, effect.duration, effect.cumulative)
    end

    def process_effects(effects, value, target, affects = nil)
      effects.each do |name|
        effect = find_effect(name)

        if effect.target == target && (affects.nil? || effect.affects == affects)
          temp = effect.func.call(value)

          value += effect.type == @enums::EffectType::BUFF ? temp : -temp

          yield [ temp, effect.type ] if block_given?
        end
      end

      value < 0 ? 0 : value
    end

    private

    def find_effect(name)
      effect = @effect_repository.find name

      raise @errors::NOT_FOUND_EFFECT if effect.nil?

      effect
    end
  end
end

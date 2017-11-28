require_relative 'entity/inner_self'

require 'forwardable'

module SnED100
  class Entity
    extend Forwardable

    def_delegators :@inner_self,
                    :max_health,
                    :max_energy,
                    :knocked_down?,
                    :unconscious?,
                    :dead?,
                    :status,
                    :experience,
                    :magics

    attr_reader :name

    def initialize(values)
      @errors = values[:errors]
      @rules = values[:rules]
      @enums = values[:enums]
      @name = values[:name]
      @effect_processor = values[:effect_processor]

      raise "ErrorCodes is required" if @errors.nil?
      raise @errors::REQUIRED_ENUMS if @enums.nil?
      raise @errors::REQUIRED_RULES if @rules.nil?
      raise @errors::REQUIRED_NAME if @name.nil?
      raise @errors::REQUIRED_EFFECT_PROCESSOR if @effect_processor.nil?

      @effects = []
      @inner_self = InnerSelf.new(values)
    end

    def health
      @inner_self.health
    end

    def damage(damage)
      check_if_above_zero(damage)

      result = @inner_self.health(Damage.new damage)

      @effects.clear if unconscious? || dead?

      result
    end

    def heal(heal)
      check_if_above_zero(heal)

      @inner_self.health(Heal.new heal)
    end

    def energy
      @inner_self.energy
    end

    def energize(gain)
      check_if_above_zero(gain)

      @inner_self.energy(Gain.new gain)
    end

    def consume(drain)
      check_if_above_zero(drain)

      @inner_self.energy(Drain.new drain)
    end

    def earn_experience(amount)
      return if knocked_down?

      @inner_self.experience amount
    end

    def spend_experience(amount)
      return if knocked_down?

      @inner_self.experience -amount
    end

    def skills
      @inner_self.skills.inject({}) {|hash, name| hash.merge!(name => skill(name)) }.freeze
    end

    def skill(name)
      if value = @inner_self.skill(name)
        @effect_processor.process_effects(effect_names, value, @enums::EffectTarget::SKILL, name.to_sym)
      end
    end

    def learn_skill(name, influenced)
      @inner_self.learn_skill(name, influenced)
    end

    def train_skill(name)
      @inner_self.train_skill(name)
    end

    def attributes
      @inner_self.attributes.inject({}) {|hash, name| hash.merge!(name => attribute(name)) }.freeze
    end

    def attribute(name)
      if value = @inner_self.attribute(name)
        @effect_processor.process_effects(effect_names, value, @enums::EffectTarget::ATTRIBUTE, name.to_sym)
      end
    end

    def raise_attribute(name)
      @inner_self.raise_attribute(name)
    end

    def learn_magic(magic_name, skill_name)
      @inner_self.learn_magic(magic_name, skill_name)
    end

    def observation
      value = @rules.observation_distance attribute(@rules.observation_attribute)

      @effect_processor.process_effects(effect_names, value, @enums::EffectTarget::OBSERVATION)
    end

    def line_of_sight
      observation * @rules.line_of_sight_scale_factor
    end

    def movement
      value = @rules.movement attribute(@rules.movement_attribute)

      @effect_processor.process_effects(effect_names, value, @enums::EffectTarget::MOVEMENT)
    end

    def running
      movement * @rules.running_factor
    end

    def natural_damage
      @rules.natural_damage attribute(@rules.natural_damage_attribute)
    end

    def number_of_melee_attacks
      @rules.number_of_melee_attacks attribute(@rules.number_of_melee_attacks_attribute)
    end

    def melee_range
      @rules.melee_range
    end

    def add_effect(effect_name)
      effect_tracker = @effect_processor.effect_tracker(effect_name)

      #TODO: Rulechange -> Change the old effect with new effect
      return false if knocked_down? || (@effects.any? {|e| e.name == effect_tracker.name } && !effect_tracker.cumulative)

      @effects << effect_tracker

      true
    end

    def remove_effect(effect_name)
      @effects.delete_if {|effect| effect.name == effect_name }

      effects
    end

    def expire_effect(period)
      @effects.each {|effect| effect.remaining -= period }

      @effects.delete_if {|effect| effect.remaining < 0 }

      effects
    end

    def effects
      @effects.map {|effect| [ effect.name, effect.remaining ] }.freeze
    end

    private

    def effect_names
      @effects.map {|effect| effect.name }.freeze
    end

    def check_if_above_zero(value)
      raise @errors::INVALID_VALUE_NEGATIVE_OR_ZERO unless value > 0
    end
  end
end

module Simulation
  class Puppeteer
    def initialize(values)
      @entity =  values[:entity]
      @rules = values[:rules]
      @enums = values[:enums]
      @effect_processor = values[:effect_processor]

      @cooldowns = {}
      @queued_action = []
      @decision = nil
      @damaged_by = []
      @healed_by = []

      set_done @entity.dead?

      @period_in_state = 0
    end

    def damaged_by(name)
      @damaged_by << name unless @damaged_by.include? name
    end

    def healed_by(name)
      @healed_by << name unless @healed_by.include? name
    end

    def decision
      return if @queued_action.empty? || @queued_action[1] > 0

      @queued_action.clear

      @decision
    end

    def queue_decision(decision)
      return if decision[0] == @enums::EntityAction::NONE

      @decision = decision

      energy_cost = 0

      if decision[0] == @enums::EntityAction::MOVE
        @queued_action = [ decision[1], 0 ]

        energy_cost = decision[1] == @enums::MovementType::RUN ? @rules.running_energy_cost : @rules.movement_energy_cost
      else
        obj = decision[1] || decision[2]

        @queued_action = [ obj.name, obj.execution ]

        energy_cost = obj.energy_cost
      end

      if energy_cost > 0 && drain(energy_cost).nil?
        raise "#{@entity.name} - not enough energy"
      end
    end

    def on_cooldown(name, duration = nil)
      return @cooldowns.has_key? name if duration.nil?

      @cooldowns[name] = duration
    end

    def period_passed(period)
      update_state(period)

      return if @done

      rested if status == @enums::EntityStatus::UNCONSCIOUS

      process_effects(period)

      living_energy_tax if status == @enums::EntityStatus::HURT || status == @enums::EntityStatus::UNINJURIED
    end

    def set_done(is_done)
      @done ||= is_done
    end

    def done?
      @done
    end

    def info
      {
        :name => @entity.name,
        :health => @entity.health,
        :energy => @entity.energy,
        :dead => @entity.dead?,
        :unconscious => @entity.unconscious?,
        :movement => @entity.movement,
        :running => @entity.running,
        :observation => @entity.observation,
        :line_of_sight => @entity.line_of_sight,
        :attributes => @entity.attributes,
        :skills => @entity.skills,
        :magics => @entity.magics,
        :effects => @entity.effects.map {|effect| effect.name },
        :number_of_melee_attacks => @entity.number_of_melee_attacks,
        :melee_range => @entity.melee_range,
        :natural_damage => @entity.natural_damage,
        :cooldowns => @cooldowns.map { |name, duration| name },
        :charging => @queued_action[0],
        :damaged_by => @damaged_by.dup,
        :healed_by => @healed_by.dup
      }.freeze
    end

    def drain(amount)
      return if @done

      @entity.consume amount
    end

    def gain(amount)
      return if @done

      @entity.consume amount
    end

    def damage(amount)
      change_health(amount, true)
    end

    def heal(amount)
      change_health(amount, false)
    end

    def status
      @entity.status
    end

    private

    def change_health(amount, damage)
      return if @done

      old_state = status

      if damage
        @entity.damage amount
      else
        @entity.heal amount
      end

      new_state = status

      @period_in_state = 0 if old_state != new_state

      @cooldowns.clear if new_state == @enums::EntityStatus::DEAD

      if new_state == @enums::EntityStatus::DEAD ||
         new_state == @enums::EntityStatus::UNCONSCIOUS ||
         @rules.action_interrupted?(amount, @entity.max_health)
        @queued_action.clear
      end
    end

    def process_effects(period)
      @entity.expire_effect(period)

      apply_vital_effects(period)
    end

    def apply_vital_effects(period)
      effects = @entity.effects.map {|e| e.name }

      period.times do
        @effect_processor.process_effects(effects, @entity.health, @enums::EffectTarget::HEALTH) do |value, type|
          type == @enums::EffectType::BUFF ? heal(value) : damage(value)
        end

        @effect_processor.process_effects(effects, @entity.energy, @enums::EffectTarget::ENERGY) do |value, type|
          type == @enums::EffectType::BUFF ? energize(value) : consume(value)
        end
      end
    end

    def update_state(period)
      @period_in_state += period
      @queued_action[1] -= period unless @queued_action.empty?
      @cooldowns.each_key { |key| @cooldowns[key] -= period }
      @cooldowns.delete_if { |name, duration| duration < 0 }
    end

    def rested
      period = @period_in_state - @rules::minimum_rest_period

      return if period < 0

      health_gained = @rules::minimum_health_recover
      health_gained += period * @rules::health_per_hour

      energy_gained = @rules::minimum_energy_recover(@entity.max_energy)
      energy_gained = period * @rules::energy_recover_per_hour

      heal health_gained
      gain energy_gained
    end

    def living_energy_tax
      drain(@rules.energy_tax) if @period_in_state != 0 && (@period_in_state % @rules.energy_tax_interval) == 0
    end
  end
end

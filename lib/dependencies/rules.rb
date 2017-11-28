module SnED100
  class Rules
    def initialize(default_values, enums)
      @values = default_values
      @enums = enums
    end

    def max_health(attribute)
      @values.default_health * attribute +
      (attribute / @values.attr_default_value) * @values.health_scale_factor +
      (attribute / @values.supernatural_attr) * @values.health_sobrenatural_factor
    end

    def max_energy(attribute)
      @values.default_energy + attribute +
      (attribute / @values.attr_default_value) * @values.energy_scale_factor +
      (attribute / @values.supernatural_attr) * @values.energy_sobrenatural_factor
    end

    def movement(attribute)
      @values.default_movement +
      (attribute / @values.attr_default_value) * @values.movement_scale_factor +
      (attribute / @values.supernatural_attr) * @values.movement_sobrenatural_factor
    end

    def observation_distance(attribute)
      @values.default_observation +
      (attribute / @values.attr_default_value) * @values.observation_scale_factor +
      (attribute / @values.supernatural_attr) * @values.observation_sobrenatural_factor
    end

    def minimum_energy_recover(maximum_energy)
      maximum_energy / @values.energy_recover_factor
    end

    def natural_damage(attribute)
      @values.default_natural_damage + attribute / attr_default_value + (attribute / supernatural_attr) * @values.natural_damage_sobrenatural_factor
    end

    def number_of_melee_attacks(attribute)
      @values.default_number_of_melee_attacks + attribute / @values.number_of_melee_attacks_scale_value + attribute / supernatural_attr
    end

    def keep_playing?(values)
      # no action
      return false if values.empty?

      if values[:action_number] <= @values.free_movement_number_of_actions_permited &&
          values[:action] == @enums::EntityAction::MOVE
        return values[:moved] <= values[:movement] / @values.free_movement_action_factor
      end

      false
    end

    def action_interrupted?(dmg, max_health)
      dmg > Integer(max_health * damage_interruption_factor)
    end

    def roll(max = 100)
      (rand max) + 1
    end

    def initiative(puppeteers)
      puppeteers.shuffle.sort {|e1, e2| e1.info[:attributes][initiative_attribute] <=> e2.info[:attributes][initiative_attribute] }.reverse
    end

    def number_of_actions(info)
      info[:attack_type] == @enums::AttackType::MELEE ? info[:number_of_melee_attacks] : actions_per_round
    end

    private

    def method_missing(m, *args, &block)
      super unless @values.respond_to? m

      @values.send(m)
    end
  end
end

module SnED100
  class DefaultValues
    def initialize(values = {})
      @values = values
    end

    ## ATTRIBUTE ##
    def supernatural_attr
      @values[:supernatural_attr] ||= 100
    end

    def attr_default_value
      @values[:attr_default_value] ||= 10
    end

    def attribute_raising_value
      @values[:attribute_raising_value] ||= 1
    end

    def initiative_attribute
      @values[:initiative_attribute] ||= :agility
    end

    ## SKILL ##
    def skill_trainning_value
      @values[:skill_trainning_value] ||= 5
    end

    def skill_learning_value
      @values[:skill_learning_value] ||= 5
    end

    def skill_intuive_default_value
      @values[:skill_intuive_default_value] ||= 0
    end

    ## HEALTH ##
    def default_health
      @values[:default_health] ||= 2
    end

    def health_per_hour
      @values[:health_per_hour] ||= 2
    end

    def minimum_health_recover
      @values[:minimum_health_recover] ||= 8
    end

    def health_sobrenatural_factor
      @values[:health_sobrenatural_factor] ||= 4
    end

    def health_scale_factor
      @values[:health_scale_factor] ||= 2
    end

    def health_attribute
      @values[:health_attribute] ||= :vitality
    end

    ## ENERGY ##

    def default_energy
      @values[:default_energy] ||= 25
    end

    def energy_tax_interval
      @values[:energy_tax_interval] ||= 60
    end

    def energy_tax
      @values[:energy_tax] ||= 1
    end

    def energy_recover_factor
      @values[:energy_recover_factor] ||= 2
    end

    def energy_recover_per_hour
      @values[:energy_recover_per_hour] ||= 5
    end

    def energy_sobrenatural_factor
      @values[:energy_sobrenatural_factor] ||= 4
    end

    def energy_scale_factor
      @values[:energy_scale_factor] ||= 2
    end

    def running_energy_cost
      @values[:running_energy_cost] ||= 1
    end

    def energy_attribute
      @values[:energy_attribute] ||= :vitality
    end

    ## MOVEMENT ##
    def default_movement
      @values[:default_movement] ||= 50
    end

    def movement_energy_cost
      @values[:movement_energy_cost] ||= 0
    end

    def running_factor
      @values[:running_factor] ||= 3
    end

    def running_energy_cost
      @values[:running_energy_cost] ||= 1
    end

    def movement_sobrenatural_factor
      @values[:movement_sobrenatural_factor] ||= 20
    end

    def movement_scale_factor
      @values[:movement_scale_factor] ||= 25
    end

    def free_movement_action_factor
      @values[:free_movement_action_factor] ||= 2
    end

    def free_movement_number_of_actions_permited
      @values[:free_movement_number_of_actions_permited] ||= 1
    end

    def movement_attribute
      @values[:movement_attribute] ||= :agility
    end

    ## OBSERVATION ##
    def default_observation
      @values[:default_observation] ||= 5
    end

    def observation_sobrenatural_factor
      @values[:observation_sobrenatural_factor] ||= 3
    end

    def observation_scale_factor
      @values[:observation_scale_factor] ||= 4
    end

    def observation_attribute
      @values[:observation_attribute] ||= :perception
    end

    def line_of_sight_scale_factor
      @values[:line_of_sight_scale_factor] ||= 5
    end

    ## ATTACKS ##
    def default_number_of_melee_attacks
      @values[:default_number_of_melee_attacks] ||= 1
    end

    def number_of_melee_attacks_scale_value
      @values[:number_of_melee_attacks_scale_value] ||= 20
    end

    def number_of_melee_attacks_attribute
      @values[:number_of_melee_attacks_attribute] ||= :agility
    end

    ## DAMAGE ##
    def default_natural_damage
      @values[:default_natural_damage] ||= 1
    end

    def natural_damage_sobrenatural_factor
      @values[:natural_damage_sobrenatural_factor] ||= 2
    end

    def damage_interruption_factor
      @values[:damage_interruption_factor] ||= 0.4
    end

    def natural_damage_attribute
      @values[:natural_damage_attribute] ||= :strength
    end

    def kill_damage_factor
      @values[:kill_damage_factor] ||=   2
    end

    ## MISCELLANEOUS ##
    def actions_per_round
      @values[:actions_per_round] ||= 1
    end

    def minimum_rest_period
      @values[:minimum_rest_period] ||= 4 * 60
    end

    def melee_range
      @values[:melee_range] ||= 2
    end

    def round_value
      @values[:round_value] ||= 1
    end
  end
end

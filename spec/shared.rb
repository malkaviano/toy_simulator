require 'values'
require 'dependencies'
require 'repositories'
require 'entity'

module Shared
  class << self
    SnED100::SkillRepository.enums = SnED100::Enums
    SnED100::SkillRepository.init
    SnED100::EffectRepository.enums = SnED100::Enums
    SnED100::EffectRepository.init
    SnED100::MagicRepository.enums = SnED100::Enums
    SnED100::MagicRepository.init

    def rules
      SnED100::Rules.new(SnED100::DefaultValues.new, SnED100::Enums)
    end

    def effect_repository
      SnED100::EffectRepository
    end

    def skill_repository
      SnED100::SkillRepository
    end

    def magic_repository
      SnED100::MagicRepository
    end

    def error_codes
      SnED100::ErrorCodes
    end

    def enums
      SnED100::Enums
    end

    def effect_processor
      SnED100::EffectProcessor.new(:enums => enums, :errors => error_codes, :effect_repository => effect_repository)
    end

    def attr_default_value
      rules.attr_default_value
    end

    def maximum_health
      rules.max_health(attr_default_value)
    end

    def maximum_energy
      rules.max_energy(attr_default_value)
    end

    def attributes
      {
        :strength => attr_default_value,
        :agility => attr_default_value,
        :vitality => attr_default_value,
        :logic => attr_default_value,
        :perception => attr_default_value,
        :charisma => attr_default_value
      }
    end

    def skills
      SnED100::SkillRepository.intuitive_skills
    end

    def new_entity
      SnED100::Entity.new(:name => name,
      :attributes => attributes,
      :skills => skills,
      :rules => rules,
      :enums => enums,
      :errors => error_codes,
      :effect_processor => effect_processor)
    end

    def name
      "xpto"
    end

    def kill_damage
      100000
    end

    def raise_perception
      SnED100::EffectRepository.find :raise_perception
    end

    def raise_strength
      SnED100::EffectRepository.find :raise_strength
    end

    def weak_poison
      SnED100::EffectRepository.find :weak_poison
    end

    def weak_drain
      SnED100::EffectRepository.find :weak_drain
    end
  end
end

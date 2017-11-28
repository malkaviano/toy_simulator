module SnED100
  module Enums
    module EntityAction
      NONE = "none".freeze
      MOVE = "move".freeze
      SKILL = "skill".freeze
      MAGIC = "magic".freeze
    end

    module MovementType
      NORMAL = 1
      RUN = 2
    end

    module TargetType
      SELF = "self".freeze
      OTHER = "other".freeze
      POSITION = "position".freeze
    end

    module SkillType
      INTUITIVE = "intuitive".freeze
      LEARNED = "learned".freeze
    end

    module EffectType
      BUFF = "buff".freeze
      DEBUFF = "debuff".freeze
    end

    module EffectTarget
      ATTRIBUTE = "attribute".freeze
      SKILL = "skill".freeze
      MOVEMENT = "movement".freeze
      OBSERVATION = "observation".freeze
      HEALTH = "health".freeze
      ENERGY = "energy".freeze
    end

    module ActionResultSource
      ENTITY = "entity".freeze
      MIXED = "mixed".freeze
      ITEM = "item".freeze
      SKILL = "skill".freeze
      NONE = "none".freeze
    end

    module AttackType
      OTHER = 1
      MELEE = 2
    end

    module EntityStatus
      UNINJURIED = "uninjuried".freeze
      HURT = "hurt".freeze
      UNCONSCIOUS = "unconscious".freeze
      DEAD = "dead".freeze
    end

    module ActionResult
      SUCCESS = "succeeded".freeze
      FAIL = "failed".freeze
    end
  end
end

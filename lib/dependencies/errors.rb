module SnED100
  module ErrorCodes
    REQUIRED_ATTRIBUTES = "attributes are required".freeze
    REQUIRED_SKILLS = "skills are required".freeze
    REQUIRED_NAME = "name is required".freeze
    REQUIRED_ENUMS = "enums is required".freeze
    REQUIRED_RULES = "rules is required".freeze
    REQUIRED_SKILL_NAME = "skill name is required".freeze
    REQUIRED_SKILL_INFLUENCED = "skill influence attribute is required".freeze
    REQUIRED_EFFECT_REPOSITORY = "effect repository is required".freeze
    REQUIRED_EFFECT_PROCESSOR = "effect processor is required".freeze
    REQUIRED_SIZE = "size is required".freeze
    NOT_FOUND_SKILL = "skill cannot be found".freeze
    NOT_FOUND_ATTRIBUTE = "attribute cannot be found".freeze
    NOT_FOUND_EFFECT = "effect cannot be found".freeze
    SKILL_ALREADY_KNOWN = "skill already learned".freeze
    MAGIC_ALREADY_KNOWN = "magic already learned".freeze
    INVALID_ATTRIBUTE = "invalid attribute name".freeze
    INVALID_VALUE_NEGATIVE_OR_ZERO = "value must be above zero".freeze
  end
end

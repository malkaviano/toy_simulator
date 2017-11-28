module SnED100
  class InnerSelf
    attr_reader :status

    @@skill_info = Struct.new("SkillInfo", :name, :influenced, :value)

    def initialize(values)
      @errors = values[:errors]
      @rules = values[:rules]
      @enums = values[:enums]

      raise @errors::REQUIRED_ATTRIBUTES if values[:attributes].nil?
      raise @errors::REQUIRED_SKILLS if values[:skills].nil?

      @status = @enums::EntityStatus::UNINJURIED
      @attributes = {}
      @skills = {}
      @magics = {}

      values[:attributes].each {|key, value| add_attribute key, value}
      values[:skills].each {|key, value| add_skill @@skill_info.new key, value, @rules.skill_intuive_default_value}

      @health = max_health
      @energy = max_energy
      @experience = values[:experience] || 0
    end

    def max_health
      @rules.max_health attribute(@rules.health_attribute)
    end

    def max_energy
      @rules.max_energy attribute(@rules.energy_attribute)
    end

    def attributes
      @attributes.map {|key, _| key }
    end

    def attribute(name)
      @attributes[name.to_sym]
    end

    def raise_attribute(name)
      return if knocked_down?

      value = attribute name.to_sym

      raise @errors::INVALID_ATTRIBUTE if value.nil?

      @attributes[name] = value + @rules.attribute_raising_value
    end

    def skills
      @skills.map {|key, _| key }.freeze
    end

    def skill(name)
      if value = @skills[name.to_sym]&.value
        value += attribute(@skills[name.to_sym].influenced)
      end
    end

    def learn_skill(name, influenced)
      return false if knocked_down?

      raise @errors::REQUIRED_SKILL_NAME if name.nil? || name.empty?
      raise @errors::REQUIRED_SKILL_INFLUENCED if influenced.nil? || influenced.empty?
      raise @errors::NOT_FOUND_ATTRIBUTE if attribute(influenced).nil?

      add_skill @@skill_info.new(name.to_sym, influenced, @rules.skill_learning_value)

      true
    end

    def train_skill(name)
      return if knocked_down?

      raise @errors::NOT_FOUND_SKILL unless skill(name)

      @skills[name.to_sym].value += @rules.skill_trainning_value
    end

    def magics
      @magics.dup.freeze
    end

    def learn_magic(magic_name, skill_name)
      return false if knocked_down?

      magic_name = magic_name.to_sym

      raise @errors::MAGIC_ALREADY_KNOWN if @magics.has_key? magic_name
      raise @errors::NOT_FOUND_SKILL if skill(skill_name).nil?

      @magics[magic_name] = skill_name.to_sym

      true
    end

    def health(obj = nil)
      return @health if obj.nil?

      return if dead?

      @health += obj.amount

      if obj.kind_of? Damage
        damage(-obj.amount)
      else
        heal
      end
    end

    def energy(obj = nil)
      return @energy if obj.nil?

      return if dead?

      if @energy + obj.amount >= 0
        @energy += obj.amount
        @energy = max_energy if @energy > max_energy

        @energy
      end
    end

    def experience(amount = nil)
      return @experience if amount.nil?

      @experience += amount if amount + @experience >= 0
    end

    def knocked_down?
      @status == @enums::EntityStatus::DEAD || @status == @enums::EntityStatus::UNCONSCIOUS
    end

    def unconscious?
      status == @enums::EntityStatus::UNCONSCIOUS
    end

    def dead?
      status == @enums::EntityStatus::DEAD
    end

    private

    def add_attribute(name, value)
      @attributes[name.to_sym] = value.to_i
    end

    def add_skill(skill_info)
      raise @errors::SKILL_ALREADY_KNOWN unless skill(skill_info.name).nil?

      @skills[skill_info.name] = skill_info
    end

    def damage(amount)
      @health = 0 if @health < 0

      if @status == @enums::EntityStatus::UNCONSCIOUS || amount > @rules.kill_damage_factor * max_health
        @status = @enums::EntityStatus::DEAD
      elsif health == 0
        @status = @enums::EntityStatus::UNCONSCIOUS
      else
        @status = @enums::EntityStatus::HURT
      end

      @energy = 0 if knocked_down?

      @health
    end

    def heal
      @health = max_health if @health > max_health

      @status = health == max_health ? @enums::EntityStatus::UNINJURIED : @enums::EntityStatus::HURT

      @health
    end
  end
end

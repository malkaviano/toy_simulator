require_relative '../spec_helper'

describe "Entity Skills" do

  describe "#skill" do
    it "returns final value" do
      expect(Shared.new_entity.skill(:potency)).to be Shared.attr_default_value
    end

    context "when Skill cannot be found" do
      it "returns nil" do
        expect(Shared.new_entity.skill(:noting)).to be nil
      end
    end

    context "when influenced by Effects" do
      it "returns modified value" do
        entity = Shared.new_entity

        effect = Shared.effect_repository.find :improve_fight

        entity.add_effect(effect.name)

        expected = Shared.attr_default_value + effect.func.call(Shared.attr_default_value)

        expect(entity.skill :fight).to be expected
      end

    end

    context "when Effects do not affect the Skill" do
      it "returns unmodified value" do
        entity = Shared.new_entity

        effect = Shared.effect_repository.find :improve_fight

        entity.add_effect(effect.name)

        expect(entity.skill :resistance).to be Shared.attr_default_value
      end
    end
  end

  describe "#train_skill" do
    it "returns trained value" do
      entity = Shared.new_entity

      expected = Shared.rules.skill_trainning_value

      expect(entity.train_skill :athletics).to be expected
    end

    context "skill not found" do
      it "raises error when skill does not exist" do
        expect { Shared.new_entity.train_skill :noting }.to raise_error RuntimeError, Shared.error_codes::NOT_FOUND_SKILL
      end
    end

    context "when dead" do
      it "returns nil" do
        entity = Shared.new_entity

        entity.damage(Shared.kill_damage)

        expect(entity.train_skill :athletics).to be_nil
      end
    end
  end

  describe "#learn_skill" do
    it "returns skill value" do
      entity = Shared.new_entity

      entity.learn_skill :devotion, :charisma

      expected = Shared.attr_default_value + Shared.rules.skill_trainning_value

      expect(entity.skill :devotion).to be (expected)
    end

    context "when the Skill is already known" do
      it "raises error" do
        entity = Shared.new_entity

        entity.learn_skill :devotion, :charisma

        expect { entity.learn_skill :devotion, :charisma }.to raise_error RuntimeError, Shared.error_codes::SKILL_ALREADY_KNOWN
      end
    end

    context "when the Skill name is missing" do
      it "raises error" do
        entity = Shared.new_entity

        expect { entity.learn_skill nil, :charisma }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_SKILL_NAME
      end
    end

    context "when the Skill influence Attribute is missing" do
      it "raises error" do
        entity = Shared.new_entity

        expect { entity.learn_skill :devotion, "" }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_SKILL_INFLUENCED
      end
    end

    context "when the Skill influence Attribute cannot be find" do
      it "raises error" do
        entity = Shared.new_entity

        expect { entity.learn_skill :devotion, :noting }.to raise_error RuntimeError, Shared.error_codes::NOT_FOUND_ATTRIBUTE
      end
    end

    context "when unconscious" do
      it "returns false" do
        entity = Shared.new_entity

        entity.damage(entity.health)

        expect(entity.learn_skill :devotion, :charisma).to be false
      end
    end
  end

  describe "#skills" do
    it "returns a list with skill names" do
      expected = Shared.skills.map {|k, v| k }.inject({}) {|hash, name| hash.merge!(name => Shared.attr_default_value)}

      expect(Shared.new_entity.skills).to be == expected
    end
  end
end

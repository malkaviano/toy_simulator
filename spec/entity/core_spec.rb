require_relative '../spec_helper'

describe SnED100::Entity do

  describe "#name" do
    it "returns name" do
      expect(Shared.new_entity.name).to be == Shared.name
    end
  end

  describe "#movement" do
    it "returns default movement" do
      expect(Shared.new_entity.movement).to be Shared.rules.movement(Shared.attr_default_value)
    end

    context "when affected by Effects" do
      it "returns modified movement" do
        entity = Shared.new_entity

        effect = Shared.effect_repository.find :glued

        entity.add_effect(effect.name)

        expected = Shared.rules.movement(Shared.attr_default_value) - effect.func.call(Shared.rules.movement(Shared.attr_default_value))

        expect(entity.movement).to be expected
      end
    end
  end

  describe "#running" do
    it "returns running" do
      expected = Shared.rules.running_factor * Shared.rules.movement(Shared.attr_default_value)

      expect(Shared.new_entity.running).to be expected
    end
  end

  describe "#initialize" do
    context "when name is nil" do
      it "raises error" do
        expect {
          SnED100::Entity.new(
          {
            :attributes => Shared.attributes,
            :skills => Shared.skills,
            :errors => Shared.error_codes,
            :rules => Shared.rules,
            :enums => Shared.enums,
            :effect_processor => Shared.effect_processor
          })
        }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_NAME
      end
    end

    context "when skills is nil" do
      it "raises error" do
        expect {
          SnED100::Entity.new(
          {
            :name => Shared.name,
            :attributes => Shared.attributes,
            :errors => Shared.error_codes,
            :rules => Shared.rules,
            :enums => Shared.enums,
            :effect_processor => Shared.effect_processor
          })
        }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_SKILLS
      end
    end

    context "when attributes is nil" do
      it "raises error" do
        expect {
          SnED100::Entity.new(
          {
            :name => Shared.name,
            :skills => Shared.skills,
            :errors => Shared.error_codes,
            :rules => Shared.rules,
            :enums => Shared.enums,
            :effect_processor => Shared.effect_processor
          })
        }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_ATTRIBUTES
      end
    end

    context "when error_codes is nil" do
      it "raises error" do
        expect {
          SnED100::Entity.new(
          {
            :name => Shared.name,
            :attributes => Shared.attributes,
            :skills => Shared.skills,
            :rules => Shared.rules,
            :enums => Shared.enums,
            :effect_processor => Shared.effect_processor
          })
        }.to raise_error RuntimeError, "ErrorCodes is required"
      end
    end

    context "when enums is nil" do
      it "raises error" do
        expect {
          SnED100::Entity.new(
          {
            :name => Shared.name,
            :attributes => Shared.attributes,
            :skills => Shared.skills,
            :errors => Shared.error_codes,
            :rules => Shared.rules,
            :effect_processor => Shared.effect_processor
          })
        }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_ENUMS
      end
    end

    context "when rules is nil" do
      it "raises error" do
        expect {
          SnED100::Entity.new(
          {
            :name => Shared.name,
            :attributes => Shared.attributes,
            :skills => Shared.skills,
            :errors => Shared.error_codes,
            :enums => Shared.enums,
            :effect_processor => Shared.effect_processor
          })
        }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_RULES
      end
    end

    context "when effect_processor is nil" do
      it "raises error" do
        expect {
          SnED100::Entity.new(
          {
            :name => Shared.name,
            :attributes => Shared.attributes,
            :skills => Shared.skills,
            :errors => Shared.error_codes,
            :rules => Shared.rules,
            :enums => Shared.enums
          })
        }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_EFFECT_PROCESSOR
      end
    end
  end

  describe "#experience" do
    it "returns experience" do
      entity = Shared.new_entity
      entity.earn_experience 10
      entity.spend_experience 5

      expect(entity.experience).to be 5
    end
  end

  describe "#spend_experience" do
    it "returns remaining experience" do
      entity = Shared.new_entity

      entity.earn_experience 5

      expect(entity.spend_experience 5).to be 0
    end

    context "when experience is insuficient" do
      it "returns nil" do
        entity = Shared.new_entity

        entity.earn_experience 5

        expect(entity.spend_experience 10).to be_nil
      end
    end

    context "when Entity is dead" do
      it "returns nil" do
        entity = Shared.new_entity

        entity.earn_experience 5

        entity.damage(Shared.kill_damage)

        expect(entity.spend_experience 5).to be_nil
      end
    end
  end

  describe "#earn_experience" do
    it "returns accumulated experience" do
      entity = Shared.new_entity

      expect(entity.earn_experience 5).to be 5
    end

    context "when Entity is unconscious" do
      it "returns nil" do
        entity = Shared.new_entity

        entity.damage(entity.health)

        expect(entity.earn_experience 5).to be_nil
      end
    end
  end

  describe "#observation" do
    it "returns observation distance" do
      expect(Shared.new_entity.observation).to be Shared.rules.observation_distance(Shared.attr_default_value)
    end

    context "when affected by Effects" do
      it "returns modified observation" do
        entity = Shared.new_entity

        effect = Shared.effect_repository.find :blinded

        entity.add_effect(effect.name)

        expected = Shared.rules.observation_distance(Shared.attr_default_value) - effect.func.call(Shared.rules.observation_distance(Shared.attr_default_value))

        expect(entity.observation).to be expected
      end
    end
  end

  describe "#line_of_sight" do
    it "returns line of sight" do
      expected = Shared.rules.observation_distance(Shared.attr_default_value) * Shared.rules.line_of_sight_scale_factor

      expect(Shared.new_entity.line_of_sight).to be expected
    end
  end

  describe "#natural_damage" do
    it "returns natural damage" do
      expected = Shared.rules.natural_damage(Shared.attr_default_value)

      expect(Shared.new_entity.natural_damage).to be expected
    end
  end

  describe "#number_of_melee_attacks" do
    it "returns number of attacks per round" do
      expected = Shared.rules.number_of_melee_attacks(Shared.attr_default_value)

      expect(Shared.new_entity.number_of_melee_attacks).to be expected
    end
  end
end

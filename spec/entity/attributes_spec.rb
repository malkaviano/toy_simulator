require_relative '../spec_helper'

describe "Entity Attributes" do

  describe "#attribute" do
    context "When Entity has no effects" do
      it "returns default value" do
        expect(Shared.new_entity.attribute :agility).to be Shared.attr_default_value
      end

      it "returns nil" do
        expect(Shared.new_entity.attribute :nothing).to be_nil
      end
    end

    context "When Entity has effects" do
      it "returns modified value" do
        entity = Shared.new_entity

        effect = Shared.effect_repository.find :raise_strength

        entity.add_effect(effect.name)

        expected = Shared.attr_default_value + effect.func.call(Shared.attr_default_value)

        expect(entity.attribute :strength).to be expected
      end

      it "returns default value" do
        entity = Shared.new_entity

        effect = Shared.effect_repository.find :raise_strength

        entity.add_effect(effect.name)

        expect(entity.attribute :agility).to be Shared.attr_default_value
      end
    end
  end

  describe "#attributes" do
    it "returns a list of attributes" do
      expect(Shared.new_entity.attributes).to eq Shared.attributes
    end
  end

  describe "#raise_attribute" do
    it "returns the increased value" do
      expected = Shared.attr_default_value + 1

      expect(Shared.new_entity.raise_attribute :agility).to be expected
    end

    it "raises error" do
      expect { Shared.new_entity.raise_attribute :nothing }.to raise_error RuntimeError, Shared.error_codes::INVALID_ATTRIBUTE
    end

    context "when unconscious" do
      it "returns nil" do
        entity = Shared.new_entity

        entity.damage(entity.health)

        expected = Shared.attr_default_value + 1

        expect(entity.raise_attribute :agility).to be_nil
      end
    end
  end

end

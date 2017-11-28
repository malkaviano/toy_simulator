require_relative '../spec_helper'

describe "Entity Energy" do

  describe "#max_energy" do
    it "returns maximum Energy" do
      expect(Shared.new_entity.max_energy).to be Shared.maximum_energy
    end

    context "when vitality changes" do
      it "return maximum Energy" do
        entity = Shared.new_entity

        entity.raise_attribute Shared.rules.energy_attribute

        expect(entity.max_energy).to be > Shared.maximum_energy
      end
    end
  end

  describe "#energy" do
    it "returns current Energy" do
      entity = Shared.new_entity

      expect(entity.energy).to be Shared.maximum_energy
    end

    context "when Energy is spent" do
      it "returns remaining Energy" do
        entity = Shared.new_entity

        drain = 6

        expected = Shared.maximum_energy - drain

        expect(entity.consume(drain)).to be expected
      end
    end

    context "when Energy gain is superior to maximum Energy" do
      it "returns maximum Energy" do
        entity = Shared.new_entity

        gain = 100

        entity.energize(gain)

        expect(entity.energy).to be Shared.maximum_energy
      end
    end

    context "when Energy spent is superior to current Energy" do
      it "returns nil" do
        drain = 100

        expect(Shared.new_entity.consume(drain)).to be_nil
      end
    end

    context "when Entity dies" do
      it "returns zero" do
        entity = Shared.new_entity

        entity.damage(Shared.kill_damage)

        expect(entity.energy).to be 0
      end
    end

    context "when Entity is unconscious" do
      it "returns zero" do
        entity = Shared.new_entity

        entity.damage(entity.health)

        expect(entity.energy).to be 0
      end
    end
  end
end

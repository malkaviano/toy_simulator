require_relative '../spec_helper'

describe "Entity Effects" do
  describe "#effects" do
    it "return current Effects" do
      entity = Shared.new_entity

      entity.add_effect(Shared.raise_perception.name)
      entity.add_effect(Shared.raise_strength.name)
      entity.add_effect(Shared.raise_perception.name)

      expected = [
        [ Shared.raise_perception.name, Shared.raise_perception.duration ],
        [ Shared.raise_strength.name, Shared.raise_strength.duration ],
        [ Shared.raise_perception.name, Shared.raise_perception.duration ]
      ]

      expect(entity.effects).to be == expected
    end

    it "return an empty list" do
      expect(Shared.new_entity.effects).to be == []
    end

    context "when Entity dies" do
      it "return an empty list" do
        entity = Shared.new_entity

        entity.add_effect(Shared.raise_perception.name)
        entity.add_effect(Shared.raise_strength.name)
        entity.add_effect(Shared.raise_perception.name)

        entity.damage(Shared.kill_damage)

        expect(entity.effects).to be == []
      end
    end
  end

  describe "#add_effect" do
    it "returns true" do
      expect(Shared.new_entity.add_effect(Shared.raise_perception.name)).to be true
    end

    context "the Effect being added already exists but is cumulative" do
      it "returns true" do
        entity = Shared.new_entity

        entity.add_effect(Shared.raise_perception.name)

        expect(entity.add_effect(Shared.raise_perception.name)).to be true
      end
    end

    context "the Effect being added already exists but is not cumulative" do
      it "returns false" do
        entity = Shared.new_entity

        entity.add_effect(Shared.raise_strength.name)

        expect(entity.add_effect(Shared.raise_strength.name)).to be false
      end
    end

    context "the Entity is dead" do
      it "returns false" do
        entity = Shared.new_entity

        entity.damage(Shared.kill_damage)

        expect(entity.add_effect(Shared.raise_strength.name)).to be false
      end
    end
  end

  describe "#remove_effect" do
    it "returns empty list" do
      expect(Shared.new_entity.remove_effect(Shared.raise_strength)).to be == []
    end

    it "returns the Effects list" do
      entity = Shared.new_entity

      entity.add_effect(Shared.raise_perception.name)
      entity.add_effect(Shared.raise_perception.name)
      entity.add_effect(Shared.raise_strength.name)

      expected = [ [  Shared.raise_strength.name, Shared.raise_strength.duration ] ]

      expect(entity.remove_effect(Shared.raise_perception.name)).to be == expected
    end
  end

  describe "#expire_effect" do
    context "when no Effects exist" do
      it "returns empty List" do
        expect(Shared.new_entity.expire_effect(1)).to be == []
      end
    end

    context "when Effects are expired" do
      it "returns remaining Effects" do
        entity = Shared.new_entity

        entity.add_effect(Shared.raise_perception.name)
        entity.add_effect(Shared.raise_strength.name)

        period = 6

        expected = [ [ Shared.raise_perception.name, Shared.raise_perception.duration - period ] ]

        expect(entity.expire_effect(period)).to be == expected
      end
    end
  end
end

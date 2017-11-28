require_relative '../spec_helper'

describe "Entity State" do

  context "#unconscious?" do
    context "when Entity is created" do
      it "returns false" do
        entity = Shared.new_entity

        expect(entity.unconscious?).to be false
      end
    end

    context "when health reaches zero" do
      it "returns true" do
        entity = Shared.new_entity

        entity.damage entity.health

        expect(entity.unconscious?).to be true
      end
    end

    context "when Entity is unconscious and gets healed" do
      it "returns false" do
        entity = Shared.new_entity

        entity.damage entity.health
        entity.heal 10

        expect(entity.unconscious?).to be false
      end
    end
  end

  context "#dead?" do
    it "returns true after receiving damage when unconscious" do
      entity = Shared.new_entity

      entity.damage entity.health

      entity.damage 1

      expect(entity.dead?).to be true
    end

    it "returns true if damage taken is more than two times maximum health" do
      entity = Shared.new_entity

      entity.damage Shared.kill_damage

      expect(entity.dead?).to be true
    end

    it "is false when entity is created" do
      entity = Shared.new_entity

      expect(entity.dead?).to be false
    end
  end

  context "#status" do
    it "returns UNINJURIED" do
      expect(Shared.new_entity.status).to be == Shared.enums::EntityStatus::UNINJURIED
    end

    it "returns HURT" do
      entity = Shared.new_entity

      entity.damage(1)

      expect(entity.status).to be == Shared.enums::EntityStatus::HURT
    end

    it "returns UNCONSCIOUS" do
      entity = Shared.new_entity

      entity.damage(entity.health)

      expect(entity.status).to be == Shared.enums::EntityStatus::UNCONSCIOUS
    end

    it "returns DEAD" do
      entity = Shared.new_entity

      entity.damage(Shared.kill_damage)

      expect(entity.status).to be == Shared.enums::EntityStatus::DEAD
    end
  end
end

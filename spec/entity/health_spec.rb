require_relative '../spec_helper'

describe "Entity Health" do

  describe "#max_health" do
    it "returns maximum Health" do
      expect(Shared.new_entity.max_health).to be Shared.maximum_health
    end

    context "when vitality changes"
    it "return superior maximum health" do
      entity = Shared.new_entity

      entity.raise_attribute :vitality

      expect(entity.max_health).to be > Shared.maximum_health
    end
  end

  describe "#health" do
    context "when Entity is created" do
      it "returns maximum Health" do
        expect(Shared.new_entity.health).to be Shared.maximum_health
      end
    end

    it "returns current Health" do
      entity = Shared.new_entity

      damage = 12

      expected = entity.health - 12

      expect(entity.damage(damage)).to be expected
    end

    context "when Health after a heal is superior to maximum Health" do
      it "returns maximum Health" do
        heal = 50

        expect(Shared.new_entity.heal(heal)).to be Shared.maximum_health
      end
    end    
  end
end

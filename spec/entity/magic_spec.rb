require_relative '../spec_helper'

describe "Entity Magic" do

  context "#magics" do
    it "return a list of learned Magics" do
      entity = Shared.new_entity

      entity.learn_skill(:devotion, :charisma)
      entity.learn_magic(:heal, :devotion)
      entity.learn_magic(:mass_heal, :devotion)

      expect(entity.magics).to be == {:heal => :devotion, :mass_heal => :devotion}
    end

    it "returns empty list" do
      expect(Shared.new_entity.magics).to be == {}
    end
  end

  context "#learn_magic" do
    it "retuns true" do
      entity = Shared.new_entity

      entity.learn_skill(:devotion, :charisma)

      expect(entity.learn_magic :heal, :devotion).to be true
    end

    context "learning a Magic already known" do
      it "throws exception" do
        entity = Shared.new_entity

        entity.learn_skill(:devotion, :charisma)

        entity.learn_magic(:heal, :devotion)

        expect { entity.learn_magic(:heal, :devotion) }.to raise_error RuntimeError, Shared.error_codes::MAGIC_ALREADY_KNOWN
      end
    end

    context "learning a Magic when dead" do
      it "returns false" do
        entity = Shared.new_entity

        entity.learn_skill(:devotion, :charisma)

        entity.damage(Shared.kill_damage)

        expect(entity.learn_magic(:heal, :devotion)).to be false
      end
    end
  end
end

require_relative 'spec_helper'

describe SnED100::EffectProcessor do
  describe "#initialize" do
    context "when error codes is not provided" do
      it "raises error" do
        expect {
          SnED100::EffectProcessor.new(:enums => Shared.enums, :effect_repository => Shared.effect_repository)
        }.to raise_error RuntimeError, "ErrorCodes is required"
      end
    end

    context "when enums is not provided" do
      it "raises error" do
        expect {
          SnED100::EffectProcessor.new(:errors => Shared.error_codes, :effect_repository => Shared.effect_repository)
        }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_ENUMS
      end
    end

    context "when effect repository is not provided" do
      it "raises error" do
        expect {
          SnED100::EffectProcessor.new(:errors => Shared.error_codes, :enums => Shared.enums)
        }.to raise_error RuntimeError, Shared.error_codes::REQUIRED_EFFECT_REPOSITORY
      end
    end
  end

  describe "#process_effects" do
    context "when there are no effects" do
      it "returns same value inputed" do
        effect_processor = Shared.effect_processor

        value = 10

        expect(effect_processor.process_effects([], value, Shared.enums::EffectTarget::HEALTH)).to be value
      end
    end

    context "when there are effects" do
      it "returns modified value" do
        effect_processor = Shared.effect_processor

        effect = Shared.weak_poison
        value = 10
        expected = value - effect.func.call(value)

        expect(effect_processor.process_effects([ effect.name ], value, effect.target)).to be expected
      end
    end

    context "when a block is provided" do
      it "yields result and type" do
        effect_processor = Shared.effect_processor

        effect = Shared.weak_poison
        value = 10
        expected = [ effect.func.call(value), effect.type ]

        expect {|b| effect_processor.process_effects([ effect.name ], value, effect.target, &b) }.to yield_with_args(expected)
      end
    end

    context "when Effect name is not found" do
      it "raises error" do
        expect { Shared.effect_processor.effect_tracker(:error) }.to raise_error RuntimeError, Shared.error_codes::NOT_FOUND_EFFECT
      end
    end
  end

  describe "#effect_tracker" do
    it "returns an effect tracker" do
      effect = Shared.raise_strength

      result = Shared.effect_processor.effect_tracker(effect.name)

      #Struct comparing mechanism workaround
      expected = result.class.new(effect.name, effect.duration, effect.cumulative)

      expect(result).to be == expected
    end

    context "when Effect name is not found" do
      it "raises error" do
        expect { Shared.effect_processor.effect_tracker(:error) }.to raise_error RuntimeError, Shared.error_codes::NOT_FOUND_EFFECT
      end
    end
  end
end

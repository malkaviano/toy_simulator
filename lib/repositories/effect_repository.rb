require_relative '../../infra/repository'

module SnED100
  module EffectRepository
    class << self
      include Generics::Repository

      attr_writer :enums

      def init
        @repository = {}

        add Effect.new :name => :raise_strength,
                        :duration => 5,
                        :cumulative => false,
                        :type => @enums::EffectType::BUFF,
                        :target => @enums::EffectTarget::ATTRIBUTE,
                        :affects => :strength,
                        :func => ->(strength){ 10 }

        add Effect.new :name => :raise_perception,
                        :duration => 10,
                        :cumulative => true,
                        :type => @enums::EffectType::BUFF,
                        :target => @enums::EffectTarget::ATTRIBUTE,
                        :affects => :perception,
                        :func => ->(perception){ 10 }

        add Effect.new :name => :improve_fight,
                        :duration => 5,
                        :cumulative => false,
                        :type => @enums::EffectType::BUFF,
                        :target => @enums::EffectTarget::SKILL,
                        :affects => :fight,
                        :func => ->(fight){ 25 }

        add Effect.new :name => :glued,
                        :duration => 8,
                        :cumulative => false,
                        :type => @enums::EffectType::DEBUFF,
                        :target => @enums::EffectTarget::MOVEMENT,
                        :func => ->(mov){ mov * 0.5 }

        add Effect.new :name => :blinded,
                        :duration => 3,
                        :cumulative => false,
                        :type => @enums::EffectType::DEBUFF,
                        :target => @enums::EffectTarget::OBSERVATION,
                        :func => ->(obs){ obs * 0.8 }

        add Effect.new :name => :weak_poison,
                        :duration => 10,
                        :cumulative => true,
                        :type => @enums::EffectType::DEBUFF,
                        :target => @enums::EffectTarget::HEALTH,
                        :func => ->(health){ 2 }

        add Effect.new :name => :weak_drain,
                        :duration => 4,
                        :cumulative => false,
                        :type => @enums::EffectType::DEBUFF,
                        :target => @enums::EffectTarget::ENERGY,
                        :func => ->(energy){ 10 }
      end
    end
  end
end

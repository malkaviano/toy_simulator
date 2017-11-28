require_relative '../../infra/repository'

module SnED100
  module MagicRepository
    class << self
      include Generics::Repository

      attr_writer :enums

      def init
        @repository = {}

        add Magic.new :name => :heal,
                      :heal => 5,
                      :target_types => [ @enums::TargetType::SELF, @enums::TargetType::OTHER ],
                      :energy_cost => 4,
                      :execution => 1,
                      :range => 20,
                      :skill_related => :devotion,
                      :power_cicle => 2,
                      :cooldown => 1

        add Magic.new :name => :mass_heal,
                      :heal => 5,
                      :target_types => [ @enums::TargetType::POSITION ],
                      :energy_cost => 6,
                      :execution => 2,
                      :range => 10,
                      :effective_area => 5,
                      :skill_related => :devotion,
                      :power_cicle => 4,
                      :cooldown => 3

        add Magic.new :name => :teleport,
                      :target_types => [ @enums::TargetType::POSITION ],
                      :energy_cost => 6,
                      :execution => 5,
                      :range => 30,
                      :skill_related => :arcane_arts,
                      :power_cicle => 3,
                      :cooldown => 10
      end
    end
  end
end

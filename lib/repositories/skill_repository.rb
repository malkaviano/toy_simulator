require_relative '../../infra/repository'

module SnED100
  module SkillRepository
    class << self
      include Generics::Repository

      attr_writer :enums

      def intuitive_skills
        all.select {|skill| skill.type == @enums::SkillType::INTUITIVE }.inject({}) {|hash, skill| hash.merge! skill.name => skill.influenced }
      end

      def init
        @repository = {}

        ##core
        add Skill.new :name => :potency,
                      :influenced => :strength,
                      :energy_cost => 2,
                      :execution => 0,
                      :type => @enums::SkillType::INTUITIVE,
                      :target_types => [ @enums::TargetType::SELF ],
                      :source => @enums::ActionResultSource::NONE

        add Skill.new :name => :athletics,
                      :influenced => :agility,
                      :energy_cost => 1,
                      :execution => 0,
                      :type => @enums::SkillType::INTUITIVE,
                      :target_types => [ @enums::TargetType::SELF ],
                      :source => @enums::ActionResultSource::NONE

        add Skill.new :name => :resistance,
                      :influenced => :vitality,
                      :energy_cost => 1,
                      :execution => 0,
                      :type => @enums::SkillType::INTUITIVE,
                      :target_types => [ @enums::TargetType::SELF ],
                      :source => @enums::ActionResultSource::NONE

        add Skill.new :name => :reasoning,
                      :influenced => :logic,
                      :energy_cost => 1,
                      :execution => 0,
                      :type => @enums::SkillType::INTUITIVE,
                      :target_types => [ @enums::TargetType::SELF ],
                      :source => @enums::ActionResultSource::NONE

        add Skill.new :name => :concentration,
                      :influenced => :perception,
                      :energy_cost => 1,
                      :execution => 0,
                      :type => @enums::SkillType::INTUITIVE,
                      :target_types => [ @enums::TargetType::SELF ],
                      :source => @enums::ActionResultSource::NONE

        add Skill.new :name => :influence,
                      :influenced => :charisma,
                      :energy_cost => 1,
                      :execution => 0,
                      :type => @enums::SkillType::INTUITIVE,
                      :target_types => [ @enums::TargetType::SELF ],
                      :source => @enums::ActionResultSource::NONE

        add Skill.new :name => :throw,
                      :influenced => :perception,
                      :energy_cost => 1,
                      :execution => 0,
                      :type => @enums::SkillType::INTUITIVE,
                      :target_types => [ @enums::TargetType::POSITION ],
                      :range => 10,
                      :source => @enums::ActionResultSource::ITEM

        add Skill.new :name => :fight,
                      :influenced => :agility,
                      :energy_cost => 1,
                      :execution => 0,
                      :type => @enums::SkillType::INTUITIVE,
                      :target_types => [ @enums::TargetType::OTHER ],
                      :source => @enums::ActionResultSource::ENTITY,
                      :attack_type => @enums::AttackType::MELEE

        add Skill.new :name => :arcane_arts,
                      :influenced => :logic,
                      :type => @enums::SkillType::LEARNED,
                      :source => @enums::ActionResultSource::SKILL

        add Skill.new :name => :devotion,
                      :influenced => :charisma,
                      :type => @enums::SkillType::LEARNED,
                      :source => @enums::ActionResultSource::SKILL

        ## Testing
        add Skill.new :name => :stimulate,
                      :influenced => :logic,
                      :energy_cost => 3,
                      :execution => 0,
                      :type => @enums::SkillType::LEARNED,
                      :target_types => [ @enums::TargetType::SELF ],
                      :source => @enums::ActionResultSource::NONE,
                      :effects => [ :raise_strength, :raise_perception ],
                      :cooldown => 10

        add Skill.new :name => :heroic_spit,
                      :influenced => :charisma,
                      :energy_cost => 3,
                      :execution => 0,
                      :range => 20,
                      :type => @enums::SkillType::LEARNED,
                      :target_types => [ @enums::TargetType::POSITION ],
                      :source => @enums::ActionResultSource::NONE,
                      :effective_area => 5,
                      :effects => [ :weak_poison, :weak_drain ]

        add Skill.new :name => :mega_punch,
                      :influenced => :strength,
                      :energy_cost => 6,
                      :execution => 1,
                      :cooldown => 2,
                      :damage => 10,
                      :type => @enums::SkillType::LEARNED,
                      :target_types => [ @enums::TargetType::OTHER ],
                      :source => @enums::ActionResultSource::SKILL
      end
    end
  end
end

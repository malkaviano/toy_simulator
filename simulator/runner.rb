require 'date'

require_relative '../lib/values'
require_relative '../lib/dependencies'
require_relative '../lib/repositories'

require_relative '../lib/entity'
require_relative '../lib/location'

require_relative 'scenarios'
require_relative 'maestro'
require_relative 'puppeteer'
require_relative 'projector'
require_relative 'dispatcher'
require_relative 'signals'
require_relative 'tactician'

module Simulation
  class Runner
    DATE_FORMAT = '%Y-%m-%d %H:%M:%S'.freeze

    def run(range)
      (range).each do |i|
        simulate(Scenarios.scenario(i))
      end
    end

    private
    def initialize
      @enums = SnED100::Enums
      @rules = SnED100::Rules.new(SnED100::DefaultValues.new, @enums)
      @errors = SnED100::ErrorCodes
      @effect_repository = SnED100::EffectRepository
      @skill_repository = SnED100::SkillRepository
      @magic_repository = SnED100::MagicRepository
      @effect_repository.enums = @enums
      @effect_repository.init
      @skill_repository.enums = @enums
      @skill_repository.init
      @magic_repository.enums = @enums
      @magic_repository.init
      @effect_processor = SnED100::EffectProcessor.new(:enums => @enums, :errors => @errors, :effect_repository => @effect_repository)
      Scenarios.enums = @enums
    end

    def simulate(values)
      @datetime = DateTime.now
      location = new_location(values[:size], values[:positions])

      puppeteers = []
      projectors = {}
      tacticians = {}
      values[:entities].each do |e|
        puppeteers << Puppeteer.new(:entity => new_entity(e), :enums => @enums, :rules => @rules, :effect_processor => @effect_processor)

        projectors[e[:name]] = Projector.new(:enums => @enums, :rules => @rules)

        tacticians[e[:name]] = Tactician.new(values[:tactics][e[:name]].merge(:enums => @enums)
                                                                        .merge(:rules => @rules)
                                                                        .merge(:skill_repository => @skill_repository)
                                                                        .merge(:magic_repository => @magic_repository)
                                                                        .merge(:combat => combat_skills)
                                                                        .merge(:support => support_skills))
      end

      dispatcher = Dispatcher.new(:enums => @enums)

      maestro = Maestro.new(:puppeteers => puppeteers,
                            :location => location,
                            :projectors => projectors,
                            :tacticians => tacticians,
                            :results_processor => dispatcher,
                            :enums => @enums,
                            :rules => @rules)

      puts "\nSimulation of #{values[:description]} started at #{datetime}"

      list(puppeteers, location)

      puts "\nRunning\n"

      round = maestro.run

      puts "\nFinished\n"

      list(puppeteers, location)

      puts "Simulation terminated in Round: #{round} at #{datetime}\n\n"

=begin
      puts "Action Log"

      projectors.each {|name, p| puts "Log for #{name}:"; p.log.each {|l| puts l } }
=end
    end

    def list(puppeteers, location)
      puppeteers.each do |puppeteer|
        info = puppeteer.info
        show(info, location.position(info[:name]))
      end
    end

    def show(info, position)
      p info
      p position
    end

    private

    def datetime
      @datetime.strftime DATE_FORMAT
    end

    def new_attribute_set(base)
      {
        :strength => base,
        :agility => base,
        :vitality => base,
        :logic => base,
        :perception => base,
        :charisma => base
      }
    end

    def intuitive_skills
      @skill_repository.intuitive_skills
    end

    def new_entity(values)
      e = SnED100::Entity.new(:name => values[:name],
                           :attributes => new_attribute_set(values[:attr_value]),
                           :skills => intuitive_skills,
                           :enums => @enums,
                           :rules => @rules,
                           :errors => @errors,
                           :effect_processor => @effect_processor)

      dmg = nil
      dmg = Damage.new(e.max_health) if values[:unconscious]
      dmg = Damage.new(100000) if values[:dead]
      dmg = Damage.new(values[:damage]) if values[:damage]

      e.health dmg unless dmg.nil?

      values[:learn]&.each do |skill_name|
        skill = @skill_repository.find skill_name

        e.learn_skill skill.name, skill.influenced
      end

      values[:train]&.each do |skill|
        skill[1].times { e.train_skill skill[0] }
      end

      values[:magic]&.each do |magic_name|
        magic = @magic_repository.find magic_name

        e.learn_magic(magic.name, magic.skill_related)
      end

      e
    end

    def new_location(size, positions)
      location = SnED100::Location.new(:errors => @errors, :size => size)

      positions.each {|name, position| location.insert_at name, position }

      location
    end

    def combat_skills
      [ :mega_punch, :heroic_spit, :fight ]
    end

    def support_skills
      [ :heal, :mass_heal, :stimulate ]
    end
  end
end

Simulation::Runner.new.run 1..1

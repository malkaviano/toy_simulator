module Simulation
  class Projector
    def initialize(values)
      @enums = values[:enums]
      @rules = values[:rules]
      @results = {}
      @log = []
    end

    # decision, puppeteer.info, round, location
    def project(*params)
      decision, info, round, @location = params

      @results.clear if @results[:round].nil? || @results[:round] < round || decision.nil?

      return if decision.nil?

      @results[:action_number] = (@results[:action_number] || 0) + 1

      @results[:action] = decision.shift
      info.each {|key, value| @results[key] = value }
      @results[:round] = round
      @results[:position] = @location.position(@results[:name])

      if @results[:action] == @enums::EntityAction::MOVE
        @results[:movement_type] = decision.shift
        @results[:desired_destination]  = decision.shift

        project_move
      else
        magic = decision.shift
        skill = decision.shift
        @results[:effects] = decision.shift
        @results[:target_type] = decision.shift
        @results[:target] = decision.shift
        @results[:skill_value] = info[:skills][skill.name]

        check_magic magic unless magic.nil?

        check_skill skill

        obj = magic || skill

        load_info(obj)

        check_cooldown(obj.name)

        energy_cost = @results[:energy_cost] = obj.energy_cost

        check_target(obj)

        @results[:source] = skill.source

        calculate_action_results(obj)
      end

      @log << results
    end

    def results
      @results.dup.freeze
    end

    def log
      @log.dup.freeze
    end

    private

    def load_info(obj)
      @results[:effective_area] = obj.effective_area || 0
      @results[:attack_type] = obj.attack_type
      @results[:target] = @results[:name] if @results[:target_type] == @enums::TargetType::SELF
      @results[:cooldown] = obj.cooldown
      @results[:execution] = obj.execution
      @results[:roll] = []
      @results[:action_result] = []

      if obj.range.nil?
        @results[:range] = @results[:melee_range]
      else
        @results[:range] = obj.range + @results[:observation]
      end
    end

    def calculate_action_results(obj)
      @results[:damage] = []
      @results[:heal] = []
      @results[:number_of_actions] = @rules.number_of_actions(@results)

      1.upto(@results[:number_of_actions]) do
        roll

        case @results[:source]
        when @enums::ActionResultSource::ENTITY
          @results[:damage] << @results[:natural_damage]

        when @enums::ActionResultSource::MIXED
          #mixed effective_area
        when @enums::ActionResultSource::ITEM
          #item effective_area
          #item damage
          #item heal
        when @enums::ActionResultSource::SKILL
          @results[:damage] << obj.damage
          @results[:heal] << obj.heal
        end
      end
    end

    def roll
      rolled = @rules.roll
      @results[:roll] << rolled
      @results[:action_result] << (rolled <= @results[:skill_value] ? @enums::ActionResult::SUCCESS : @enums::ActionResult::FAIL)
    end

    def project_move
      projected_distance = @location.distance(@results[:position], @results[:desired_destination])

      movement = @results[:movement]
      @results[:energy_cost] =  @rules.movement_energy_cost

      if @results[:movement_type] == @enums::MovementType::RUN
        movement = @results[:running]
        @results[:energy_cost] = @rules.running_energy_cost
      end

      distance = projected_distance.to_i

      unless @results[:moved].nil? || (movement - @results[:moved]) >= distance
        raise "#{@results[:name]} - illegal movement: tryed to move #{distance} but can only move #{(movement - @results[:moved])}"
      end

      @results[:moved] = distance

      if @location.position_occupied?(@results[:desired_destination])
        raise "#{@results[:name]} - illegal move from #{@results[:position]} to #{@results[:desired_destination]}, because it's occupied"
      end
    end

    def check_skill(skill)
      @results[:skill_name] = skill.name

      raise "Round: #{@results[:round]} - #{@results[:name]} - skill: #{@results[:skill_name]} not trained for use" if @results[:skill_value].nil?
    end

    def check_magic(magic)
      @results[:magic_name] = magic.name

      raise "Round: #{@results[:round]} - #{@results[:name]} - entity does not known the magic: #{@results[:magic_name]}" unless @results[:magics].include? magic.name

      @results[:skill_name] = magic.skill_related
    end

    def check_cooldown(obj_name)
      raise "Round: #{@results[:round]} - #{@results[:name]} - #{obj_name} is on cooldown" if @results[:cooldowns].include?(obj_name)
    end

    def check_target(obj)
      raise "Round: #{@results[:round]} - #{@results[:name]} - target type is wrong" unless obj.target_types.include? @results[:target_type]

      distance = @location.distance(@results[:position], @results[:target])

      if @results[:target_type] != @enums::TargetType::SELF
        if distance > @results[:range]
          raise "Round: #{@results[:round]} - #{@results[:name]} - target is out of range"
        end
      end
    end
  end
end

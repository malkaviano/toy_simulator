module Simulation
  class Tactician
    def initialize(values)
      @objectives = values[:objectives] || []
      @enemies = values[:enemies] || []
      @allies = values[:allies] || []
      @combat = values[:combat] || []
      @support = values[:support] || []
      @rules = values[:rules]
      @enums = values[:enums]
      @done = values[:done]
      @behaviour = values[:behaviour]
      @skill_repository = values[:skill_repository]
      @magic_repository = values[:magic_repository]
      @current_objective = []
      @destinations = []
    end

    def decision(info, location)
      @location = location
      @info = info

      @current_objective = (@objectives.shift || [ Command::STAND_BY ]) if @current_objective.empty?
      @command ||= @current_objective[0]

      case @command
      when Command::MOVE, Command::PATROL
        @destinations = get_values if @destinations.empty?

        if @info[:position] == @destinations[0]
          destination_reached
        end

        next_moving(@destinations[0])
      when Command::ATTACK, Command::SUPPORT
        target = closest_visible_target(get_values)

        process_command(target, @command)
      else
        ally = closest_visible_target(@allies)
        enemy = nil
        command = nil

        if @behaviour == Behaviour::AGGRESSIVE
          enemies = closest_visible_target(@enemies)
          command = Command::ATTACK
        elsif @behaviour == Behaviour::SUPPORT
          enemy = closest_visible_target(@info[:damaged_by])
          command = ally ? Command::SUPPORT : Command::ATTACK
        end

        result = process_command(ally || enemy, command)

        # if it's charging and the decision is the same, let the charged action go
        if @info[:charging] && result[0] != @enums::EntityAction::MOVE && @info[:charging] == (result[1] || result[2])&.name
          result = stand_by
        end

        result
      end
    end

    def done?(values)
      @done.call(values)
    end

    private

    def process_command(target, command)
      if target
        engage(target, command)
      else
        clear_intentions

        stand_by
      end
    end

    def get_values
      @current_objective[1 .. -1]
    end

    def clear_intentions
      @current_objective.clear
      @destinations.clear
      @command = nil
    end

    def engage(target_info, command)
      target, target_position, distance = target_info

      filters = command == Command::ATTACK ? {:combat => true} : {:support => true}

      magic, skill = choose(filters, distance, @info[:target_status][target])

      return stand_by if magic.nil? && skill.nil?

      choosen = (magic || skill)
      effects = choosen.effects
      range = choosen.range.nil? ? @info[:melee_range] : choosen.range + @info[:observation]

      if range >= distance
        action_type = magic.nil? ? @enums::EntityAction::SKILL : @enums::EntityAction::MAGIC

        [ action_type, magic, skill, effects, target_type(target), target ]
      else
        destination = @location.approach(@info[:name], target_position, range)

        next_moving(destination)
      end
    end

    def choose(filters, distance, status)
      magics, skills = get_usable(filters)

      func = filters[:combat] ? ->(a) { damage_of(a) } : ->(a) { (a.heal || 0) }
      func = ->(a) { (a.effects&.size || 0) } if filters[:support] && status == @enums::EntityStatus::UNINJURIED

      magics = sort_by(magics, func)
      skills = sort_by(skills, func)

      magic = get_in_range(magics, distance)

      skill = nil

      if magic.nil?
        skill = get_in_range(skills, distance)
      else
        skill = @skill_repository.find(magic.skill_related)
      end

      if status == @enums::EntityStatus::UNINJURIED && magic&.name.to_s.include?("heal")
        magic = nil
        skill = nil
      end

      [ magic, skill ]
    end

    def get_in_range(collection, distance)
      #Select the first that is in range OR the best one
      collection.select {|magic| range_of(magic) >= distance }.first ||
      collection[0]
    end

    def range_of(action)
      if action.range.nil?
        @info[:melee_range]
      else
        action.range + @info[:observation]
      end
    end

    def sort_by(collection, criteria)
      collection.sort_by {|a| criteria.call(a) }.reverse
    end

    def damage_of(action)
      case action.source
      when @enums::ActionResultSource::SKILL
        action.damage
      when @enums::ActionResultSource::ENTITY
        @info[:natural_damage]
      else
        0
      end
    end

    def get_usable(filters)

      magics = filter_usable(@magic_repository, filters, @info[:magics])

      skills = filter_usable(@skill_repository, filters, @info[:skills])

      [ magics, skills ]
    end

    def filter_usable(repository, filters, collection)
      repository.all.select do |item|
        collection.include?(item.name) &&
        (!filters[:combat] || @combat.include?(item.name)) &&
        (!filters[:support] || @support.include?(item.name)) &&
        !@info[:cooldowns].include?(item.name) &&
        item.energy_cost <= @info[:energy] &&
        !(item.target_types & [ @enums::TargetType::POSITION, @enums::TargetType::OTHER ]).empty?
      end
    end

    def closest_visible_target(targets)
      @info[:visible_to].sort_by {|t| t[2] }.each do |target|
        return target if targets.include?(target[0]) && @info[:target_status][target[0]] != @enums::EntityStatus::DEAD
      end

      nil
    end

    def next_moving(destination)
      return stand_by if destination.nil?

      movement = @round == @info[:round] ? @remaining : @info[:movement]
      new_pos = @location.project(@info[:position], destination, movement)

      @remaining = @info[:movement] - @location.distance(@info[:position], new_pos).ceil
      @round = @info[:round]

      [ @enums::EntityAction::MOVE, @enums::MovementType::NORMAL, new_pos ]
    end

    def destination_reached
      if  @command == Command::MOVE
        clear_intentions
      else
        @destinations.rotate!
      end
    end

    def target_type(target)
      target.kind_of?(String) ? @enums::TargetType::OTHER : @enums::TargetType::POSITION
    end

    def stand_by
      [ @enums::EntityAction::NONE ]
    end
  end
end

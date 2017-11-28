module Simulation
  class Dispatcher
    def initialize(values)
      @enums = values[:enums]
    end

    def dispatch(values, puppeteers, location)
      return if values.empty?

      @puppeteers = puppeteers.inject({}) {|hash, puppeteer| hash.merge! puppeteer.info[:name] => puppeteer }
      @location = location

      if values[:action] == @enums::EntityAction::MOVE
        move_to(values)
      else
        execute values
      end
    end

    private
    def move_to(values)
      @location.move_to(values[:name], values[:desired_destination])
    end

    def execute(values)
      @puppeteers[values[:name]].on_cooldown(values[:magic_name] || values[:skill_name], values[:cooldown]) unless values[:cooldown].nil?

=begin
      if values[:target].kind_of? String
        @targets = [ values[:target] ]
      else
        @targets = @location.targets_in_area(values[:target], values[:effective_area])
      end
=end

      @targets = @location.targets_in_area(values[:target], values[:effective_area])

      @targets.each do |target|
        values[:action_result].select {|ar| ar == @enums::ActionResult::SUCCESS }.each.with_index do |_, i|

          unless values[:damage][i].nil?
            @puppeteers[target].damage(values[:damage][i])
            @puppeteers[target].damaged_by(values[:name]) unless target == values[:name]
          end

          values[:effects]&.each do |effect_name|
            @puppeteers[target].add_effect(effect_name)
          end

          unless values[:heal][i].nil?
            @puppeteers[target].heal(values[:heal][i])
            @puppeteers[target].healed_by(values[:name]) unless target == values[:name]
          end
        end
      end
    end
  end
end

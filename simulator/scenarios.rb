module Simulation
  module Scenarios
    class << self
      attr_writer :enums

      def scenario(number, logger = nil)
        self.send("scenario#{number}", logger)
      end

      private

      ## simply moving around
      def scenario1(logger)
        entities = [
                    {:name => "weak", :attr_value => 5},
                    {:name => "normal", :attr_value => 10, :learn => [ :mega_punch ], :train => [ [ :mega_punch, 5 ] ]},
                    {
                      :name => "superior",
                      :attr_value => 20,
                      :learn => [ :devotion, :stimulate ],
                      :train => [ [ :devotion, 5 ], [ :stimulate, 5 ] ],
                      :magic => [ :heal ]
                    }
                  ]

        positions = { "weak" => [2, 1], "normal" => [5, 1], "superior" => [8, 1] }

        size = [10000, 10000]

        tactics = {
                    "weak" =>
                    {
                      :objectives => [ [ Command::MOVE, [ 2, 1480 ] ], [ Command::ATTACK, "normal" ] ],
                      :done => lambda {|values| values[:round] > 200 },
                      :behaviour => Behaviour::NONE
                    },
                    "normal" =>
                    {
                      :objectives => [ [ Command::MOVE, [ 5, 1500 ] ] ],
                      :done => lambda {|values| values[:round] > 200 },
                      :behaviour => Behaviour::SUPPORT
                    },
                    "superior" =>
                    {
                      :objectives => [ [ Command::MOVE, [ 8, 1490 ] ] ],
                      :done => lambda {|values| values[:round] > 200 },
                      :behaviour => Behaviour::SUPPORT,
                      :allies => ["weak"]
                    }
                  }

        {
          :description => "Scenario 1 - Moving around, pursuing and patroling",
          :size => size,
          :positions => positions,
          :entities => entities,
          :tactics => tactics
        }
      end

      ## energy drain every hour, time until energy exhaustion
      def scenario2(logger)
        entities = [
                    {:name => "weak", :attr_value => 5},
                    {:name => "normal", :attr_value => 10},
                    {:name => "superior", :attr_value => 20}
                   ]

        positions = { "weak" => [2, 1], "normal" => [5, 1], "superior" => [8, 1] }

        size = [10, 10]

        done = lambda {|values| values[:energy] == 0 }

        {
          :description => "Scenario 2 - energy drain every hour",
          :entities => entities,
          :size => size,
          :positions => positions,
          :done => done
        }
      end

      ## dead and unconscious, resting effect
      def scenario3(logger)
        entities =  [
                      {:name => "dead", :attr_value => 10, :dead => true},
                      {:name => "unconscious", :attr_value => 10, :unconscious => true}
                    ]

        positions = { "dead" => [2, 2], "unconscious" => [4, 4] }

        size = [10, 10]

        done = lambda {|values| values[:health] > 0 }

        {
          :description => "Scenario 3 - resting",
          :size => size,
          :positions => positions,
          :entities => entities,
          :done => done }
      end

      ## fight between a superior and a normal entity.
      def scenario4(logger)
        entities = [
                    {:name => "normal", :attr_value => 10, :train => [[:fight, 5]]},
                    {:name => "superior", :attr_value => 20}
                   ]

        positions = { "normal" => [2, 2], "superior" => [4, 4] }

        size = [10, 10]

        done = lambda {|values| values[:round] > 10 }

        actions = ->(values) do
          if (values[:energy] > 0)
            target = values[:name] == "superior" ? "normal" : "superior"
            [ @enums::EntityAction::SKILL, :fight, @enums::TargetType::OTHER, target ]
          else
            [ @enums::EntityAction::NONE ]
          end
        end

        {
          :description => "Scenario 4 - fight between a superior and a normal entity",
          :entities => entities,
          :size => size,
          :positions => positions,
          :done => done,
          :actions => actions
        }
      end

      ## using skill on position to do area damage and apply effect
      def scenario5(logger)
        entities = [
                    {:name => "spitter", :attr_value => 10, :learn => [:heroic_spit], :train => [[:heroic_spit, 20]]},
                    {:name => "victim1", :attr_value => 10},
                    {:name => "victim2", :attr_value => 10},
                    {:name => "no_victim", :attr_value => 10}
                   ]

        positions = { "spitter" => [5, 5],  "victim1" => [18, 18], "victim2" => [22, 22], "no_victim" => [40, 40] }

        size = [100, 100]

        done = lambda {|values| values[:round] > 6 }

        actions = ->(values) do
          if values[:name] == "spitter" && values[:round] < 3
            [ @enums::EntityAction::SKILL, :heroic_spit, @enums::TargetType::POSITION, [20, 20] ]
          else
            [ @enums::EntityAction::NONE ]
          end
        end

        {
          :description => "Scenario 5 - using skill on position to do area damage and apply effect",
          :entities => entities,
          :size => size,
          :positions => positions,
          :done => done,
          :actions => actions
        }
      end

      ## using skill with effect on self
      def scenario6(logger)
        entities = [
                    {:name => "normal", :attr_value => 10, :learn => [:stimulate], :train => [[:stimulate, 20]]}
                   ]

        positions = { "normal" => [5, 5] }

        size = [10, 10]

        done = lambda {|values| values[:round] > 11 }

        actions = ->(values) do
          if values[:round] < 3
            [ @enums::EntityAction::SKILL, :stimulate, @enums::TargetType::SELF ]
          else
            [ @enums::EntityAction::NONE ]
          end
        end

        {
          :description => "Scenario 6 - using skill with effect on self",
          :entities => entities,
          :size => size,
          :positions => positions,
          :done => done,
          :actions => actions
        }
      end

      ## using magic to heal self and other
      def scenario7(logger)
        entities = [
                    {:name => "healer", :attr_value => 10, :learn => [:devotion], :train => [[:devotion, 5]], :magic => [:heal], :damage => 20},
                    {:name => "normal", :attr_value => 10, :damage => 20}
                   ]

        positions = { "normal" => [80, 80],  "healer" => [10, 10] }

        size = [100, 100]

        done = lambda {|values| values[:round] > 10 }

        actions = ->(values) do
          if values[:name] == "healer"
            distance_to = values[:visible_to][0][2]
            target_position = values[:visible_to][0][1]
            if distance_to > 20
              movement = values[:movement] - 10 # diagonal compensation, pure guess for testing only
              position = values[:position]

              position[0] += values[:position][0] > target_position[0] ? -movement : movement
              position[1] += values[:position][1] > target_position[1] ? -movement : movement

              [ @enums::EntityAction::MOVE, @enums::MovementType::NORMAL, position ]
            elsif values[:energy] > 5 && values[:charging].nil?
              if values[:round] % 3 == 0
                [ @enums::EntityAction::MAGIC, :heal, @enums::TargetType::SELF ]
              else
                [ @enums::EntityAction::MAGIC, :heal, @enums::TargetType::OTHER, "normal" ]
              end
            else
              [ @enums::EntityAction::NONE ]
            end
          else
            [ @enums::EntityAction::NONE ]
          end
        end

        {
          :description => "Scenario 7 - using magic to heal self and other",
          :entities => entities,
          :size => size,
          :positions => positions,
          :done => done,
          :actions => actions
        }
      end

      ## using magic to heal everybody in an area
      def scenario8(logger)
        entities = [
                    {:name => "healer", :attr_value => 10, :learn => [:devotion], :train => [[:devotion, 5]], :magic => [:mass_heal], :damage => 20},
                    {:name => "healed", :attr_value => 10, :damage => 20},
                    {:name => "not_healed", :attr_value => 10, :damage => 20}
                   ]

        positions = { "healed" => [5, 5],  "healer" => [10, 10], "not_healed" => [20, 20] }

        size = [30, 30]

        done = lambda {|values| values[:round] > 20 }

        actions = ->(values) do
          if values[:name] == "healer" && values[:energy] > 5 && !values[:cooldowns]&.include?(:mass_heal)
            [ @enums::EntityAction::MAGIC, :mass_heal, @enums::TargetType::POSITION, [7, 7] ]
          else
            [ @enums::EntityAction::NONE ]
          end
        end

        {
          :description => "Scenario 8 - using magic to heal everybody in an area",
          :entities => entities,
          :size => size,
          :positions => positions,
          :done => done,
          :actions => actions
        }
      end

      ## magic interrupted by damage.
      def scenario9(logger)
        entities = [
                    {:name => "charger", :attr_value => 10, :learn => [:arcane_arts], :magic => [:teleport]},
                    {:name => "interruptor", :attr_value => 10, :learn => [:mega_punch], :train => [[:mega_punch, 16]]}
                   ]

        positions = { "charger" => [2, 2], "interruptor" => [4, 4] }

        size = [10, 10]

        done = lambda {|values| values[:round] > 2 }

        actions = ->(values) do
          if values[:round] < 2 && values[:name] == "charger"
            [ @enums::EntityAction::MAGIC, :teleport, @enums::TargetType::POSITION, [9, 9] ]
          elsif values[:round] > 1 && values[:name] == "interruptor"
            [ @enums::EntityAction::SKILL, :mega_punch, @enums::TargetType::OTHER, "charger" ]
          else
            [ @enums::EntityAction::NONE ]
          end
        end

        {
          :description => "Scenario 9 - magic interrupted by damage",
          :entities => entities,
          :size => size,
          :positions => positions,
          :done => done,
          :actions => actions
        }
      end
    end
  end
end

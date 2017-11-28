module Simulation
  class Maestro
    MAXIMUM_ROUNDS = 10000
    INFINITE_LOOP_ERROR = "probable infinite loop, aborted after too many rounds".freeze

    def initialize(values)
      @puppeteers = values[:puppeteers]
      @location = values[:location]
      @projectors = values[:projectors]
      @tacticians = values[:tacticians]
      @dispatcher = values[:results_processor]
      @enums = values[:enums]
      @rules = values[:rules]
      @round = values[:round] || 0
    end

    def run
      begin
        start_round

        initiative.each.with_index do |puppeteer, order|
          puppeteer.period_passed @rules.round_value

          info = puppeteer.info

          puppeteer.set_done(@tacticians[info[:name]].done?(args(info, order)))

          unless puppeteer.done? || info[:unconscious]
            projector = @projectors[info[:name]]

            begin
              info = args(puppeteer.info, order)

              decision = @tacticians[info[:name]].decision(info, @location.public_interface)

              puppeteer.queue_decision(decision)

              projector.project puppeteer.decision, info, @round, @location.public_interface

              results = projector.results

              @dispatcher.dispatch results, @puppeteers, @location

            end while @rules.keep_playing? results
          end

        end
      end until(@puppeteers.all? { |puppeteer| puppeteer.done? })

      @round
    end

    private

    def args(info, order)
      hash = Hash[info]

      hash[:round] = @round
      hash[:position] = @location.position hash[:name]
      hash[:order] = order
      #TODO: Merge both, Entity should be inside the Location
      hash[:visible_to] = @location.visible_to hash[:name], hash[:line_of_sight]
      hash[:target_status] = @puppeteers.inject({}) {|hash, puppeteer| hash.merge!(puppeteer.info[:name] => puppeteer.status) }

      hash.freeze
    end

    def start_round
      @round += @rules.round_value

      raise INFINITE_LOOP_ERROR if @round > MAXIMUM_ROUNDS
    end

    def initiative
      @rules.initiative @puppeteers
    end
  end
end

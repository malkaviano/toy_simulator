require 'matrix'
require 'forwardable'

module SnED100
  class Location
    extend Forwardable

    def_delegators :public_interface,
                    :position_occupied?,
                    :targets_in_area,
                    :visible_to,
                    :size,
                    :position,
                    :valid_position?,
                    :distance,
                    :project,
                    :approach

    def initialize(values)
      @size = values[:size].freeze
      @errors = values[:errors].freeze

      raise "ErrorCodes is required" if @errors.nil?
      raise @errors::REQUIRED_SIZE if @size.nil?

      @occupied = {}
    end

    def insert_at(name, position)
      if valid_position?(position)
        @occupied[name] = position.freeze
      end
    end

    def remove(name)
      @occupied.delete(name)
    end

    def public_interface
      @public_interface ||= PublicInterface.new(@size, @occupied)
    end

    alias_method :move_to, :insert_at

    class PublicInterface
      def initialize(size, occupied)
        @size = size
        @occupied = occupied
      end

      def position_occupied?(position)
        @occupied.any? {|key, value| value == position }
      end

      def targets_in_area(target_position, effect_area)
        target_position = position(target_position) if target_position.kind_of? String

        u = target_position[0] - effect_area
        l = target_position[1] - effect_area
        r = target_position[1] + effect_area
        d = target_position[0] + effect_area

        @occupied.select {|_, value| value[0].between?(u, d) && value[1].between?(l, r) }.map { |key, _| key }
      end

      def visible_to(name, max_distance)
        @occupied.select {|key, value| key != name }
                  .delete_if {|key, value| distance(name, key) > max_distance }
                  .map {|key, value| [ key, value, distance(name, key).ceil ] }
      end

      def size
        @size
      end

      def position(name)
        return @occupied[name] if @occupied.has_key? name
      end

      def valid_position?(position)
        valid = true

        0.upto(1) {|i| valid = valid && position[i] >= 0 && position[i] <= size[i] }

        valid && !position_occupied?(position)
      end

      def distance(origin, destination)
        origin = to_position(origin)
        destination = to_position(destination)

        v1 = to_vector(origin)
        v2 = to_vector(destination)

        (v2 - v1).magnitude
      end

      def project(origin, destination, movement)
        origin = to_position(origin)
        destination = to_position(destination)

        v1 = to_vector(origin)
        v2 = to_vector(destination)

        distance = distance(origin, destination)

        movement = distance if movement > distance

        diff = v2 - v1

        v = (diff.normalize * movement) + v1

        x = diff[0] < 0 ? v[0].ceil : v[0].to_i
        y = diff[1] < 0 ? v[1].ceil : v[1].to_i

        if [ x, y ] == origin
          x1 = diff[0] < 0 ? x - 1 : x + 1
          y1 = diff[1] < 0 ? y - 1 : y + 1

          valid_position?([x1, y]) ? x = x1 : y = y1
        end

        [ x, y ]
      end

      def approach(name, target, range)
        d = distance(name, target)

        project(name, target, (d - range).ceil)
      end

      private

      def to_position(obj)
        obj = position(obj) if obj.kind_of? String

        obj
      end

      def to_vector(p)
        Vector.elements(p)
      end
    end

    private_constant :PublicInterface
  end
end

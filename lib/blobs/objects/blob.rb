module Blobs
  # Any kind of blob (entity or projectile)
  class Blob < GameObject
    attr_reader :radius, :destinations

    def alive?; @alive end
    def delta; $window.delta end
    def moving?; !@destinations.empty? end

    class << self
      attr_accessor :shader, :image
    end

    def initialize(options = {})
      options = {
          angle: rand(360),
      }.merge! options

      self.class.shader ||= Ashton::Shader.new fragment: fragment_path("blob")

      @radius = options[:radius] || raise

      self.class.image ||= begin
        texture = Ashton::Texture.new @radius * 2, @radius * 2
        texture.clear color: Color::WHITE
        texture
      end

      @destinations = []
      @texture = self.class.image
      @alive = true
      @speed = options[:speed] || raise # pixels per second.

      super options

      parent.add self
    end

    def move_towards(x, y)
      @destinations << { x: x, y: y }
    end

    def stop
      @destinations.clear
    end

    def update
      max_distance = @speed * delta
      while moving? && max_distance > 0
        destination = @destinations.first

        # Work out the length of the line and then how far we can move along it.
        length_of_segment = distance_to destination[:x], destination[:y]
        distance_travelled = [length_of_segment, max_distance].min
        max_distance -= distance_travelled
        angle = Gosu::angle x, y, destination[:x], destination[:y]

        self.x += offset_x angle, distance_travelled
        self.y += offset_y angle, distance_travelled

        self.angle = angle

        # Move on to the next segment.
        @destinations.shift if distance_to(destination[:x], destination[:y]) < 0.01
      end
    end

    def draw
      self.class.shader.seed = __id__ % 10000
      self.class.shader.color = color
      @texture.draw x - radius, y - radius, nil
    end

    def touching?(other)
      alive? && other.alive? && distance_to(other) < radius + other.radius
    end

    def distance_to(*args)
      case args.size
        when 1
          other = args.first
          distance x, y, other.x, other.y
        when 2
          other_x, other_y = *args
          distance x, y, other_x, other_y
        else
          raise
      end
    end

    def die!
      parent.remove self
      @alive = false
    end

    def to_s
      "#{self.class} (#{x.round}, #{y.round})"
    end
  end
end
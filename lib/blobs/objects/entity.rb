module Blobs
  class Entity < GameObject
    SELECTED_COLOR = Color.rgb 0, 255,  0
    UNSELECTED_COLOR = Color.rgb 0, 150, 0

    SELECTED_MOVE_COLOR = Color.rgba 100, 255, 100, 100
    UNSELECTED_MOVE_COLOR = Color.rgba 100, 100, 100, 100

    MIN_DRAG_SEGMENT_DISTANCE = 10 # Pixel length of move segments when dragging.

    attr_reader :radius

    def delta; $window.delta; end
    def selected?; @selected end
    def select
      @selected = true
      self.color = SELECTED_COLOR
    end
    def deselect
      @selected = false
      self.color = UNSELECTED_COLOR
    end
    def moving?; !@destinations.empty? end

    class << self
      attr_accessor :shader, :images
    end

    def initialize(options = {})
      Entity.images ||= {}
      Entity.shader ||= Ashton::Shader.new fragment: fragment_path("blob")

      @radius = options[:radius] || raise

      Entity.images[@radius] ||= begin
        texture = Ashton::Texture.new @radius * 2, @radius * 2
        texture.clear color: Color::WHITE
        texture
      end

      options = {
          zorder: ZOrder::ENTITY,
          color: UNSELECTED_COLOR,
      }.merge! options

      @destinations = []
      @texture = Entity.images[@radius]

      @speed = options[:speed] || raise # pixels per second.

      super options
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

    def move_towards(x, y)
      @destinations << { x: x, y: y }
    end

    def dragged_to(x, y)
      last_position = @destinations.last
      last_position = { x: self.x, y: self.y } unless last_position
      if distance(last_position[:x], last_position[:y], x, y) > MIN_DRAG_SEGMENT_DISTANCE
        move_towards x, y
      end
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
      Entity.shader.seed = __id__ % 10000
      Entity.shader.color = color
      @texture.draw x - radius, y - radius, nil
    end

    def draw_lines
      return unless moving?

      color = selected? ? SELECTED_MOVE_COLOR : UNSELECTED_MOVE_COLOR

      # Current move segment.
      destination = @destinations.first
      $window.draw_line x, y, color,
                        destination[:x], destination[:y], color,
                        ZOrder::MOVE_LINE, :add


      # Future move segments, after the current one is complete.
      @destinations.each_cons 2 do |from, to|
        $window.draw_line from[:x], from[:y], color,
                          to[:x], to[:y], color,
                          ZOrder::MOVE_LINE, :add
      end
    end
  end
end
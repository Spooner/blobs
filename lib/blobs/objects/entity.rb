require_relative "blob"

module Blobs
  # An intelligent blob.
  class Entity < Blob
    SELECTED_COLOR = Color.rgb 0, 255,  0
    UNSELECTED_COLOR = Color.rgb 0, 150, 0

    SELECTED_MOVE_COLOR = Color.rgba 100, 255, 100, 100
    UNSELECTED_MOVE_COLOR = Color.rgba 100, 100, 100, 100

    MIN_DRAG_SEGMENT_DISTANCE = 10 # Pixel length of move segments when dragging.

    def selected?; @selected end
    def select
      @selected = true
      self.color = SELECTED_COLOR
    end
    def deselect
      @selected = false
      self.color = UNSELECTED_COLOR
    end

    def initialize(options = {})
      options = {
          zorder: ZOrder::ENTITIES,
          color: UNSELECTED_COLOR,
      }.merge! options

      super options
    end

    def dragged_to(x, y)
      last_position = destinations.last
      last_position = { x: self.x, y: self.y } unless last_position
      if distance(last_position[:x], last_position[:y], x, y) > MIN_DRAG_SEGMENT_DISTANCE
        move_towards x, y
      end
    end

    def draw_path_lines
      return unless moving?

      color = selected? ? SELECTED_MOVE_COLOR : UNSELECTED_MOVE_COLOR

      # Current move segment.
      destination = destinations.first
      $window.draw_line x, y, color,
                        destination[:x], destination[:y], color,
                        ZOrder::MOVE_LINE


      # Future move segments, after the current one is complete.
      destinations.each_cons 2 do |from, to|
        $window.draw_line from[:x], from[:y], color,
                          to[:x], to[:y], color,
                          ZOrder::MOVE_LINE
      end
    end

    def collides_with(other)
      if self.eats? other
        other.die!
      elsif other.eats? self
        die!
      else
        [self, other].sample.die!
      end
    end
  end
end
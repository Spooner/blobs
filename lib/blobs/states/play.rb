module Blobs
  class Play < GameState
    def delta; $window.delta end
    def mouse_x; $window.mouse_x end
    def mouse_y; $window.mouse_y end

    def setup
      @entities = []

     100.times do
        klass = [Eater, Darter, Darter, Spitter, Spitter, Spitter].sample
        pos = { x: rand($window.width), y: rand($window.height) }
        @entities << klass.new(pos)
      end

      @selected = nil

      on_input :left_mouse_button, :on_clicked
      on_input :right_mouse_button, :deselect
    end

    def deselect
      if @selected
        @selected.deselect
        @selected = nil
      end
    end

    def on_clicked
      over = @entities.find do |e|
        e.distance_to(mouse_x, mouse_y) < e.radius
      end

      if !@selected || (over && over != @selected)
        @selected.deselect if @selected
        @selected = over
        @selected.select if @selected
      else
        @selected.stop unless holding_any? :left_shift, :right_shift
        @selected.move_towards mouse_x, mouse_y
      end
    end

    def update
      Entity.shader.time = milliseconds / 1000.0

      if @selected && holding?(:left_mouse_button)
        @selected.dragged_to mouse_x, mouse_y
      end

      @entities.each &:update
    end

    def draw
      @entities.each &:draw_lines

      Entity.shader.use do
        @entities.each &:draw
      end
    end
  end
end
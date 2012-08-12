module Blobs
  class Play < GameState
    def delta; $window.delta end
    def mouse_x; $window.mouse_x end
    def mouse_y; $window.mouse_y end

    def setup
      @blobs = Hash.new {|h, k| h[k] = [] }
      @entities = []
      @projectiles = []

      100.times do
        klass = [Eater, Darter, Darter, Spitter, Spitter, Spitter].sample
        klass.new x: rand($window.width), y: rand($window.height)
      end

      perform_collisions

      @selected = nil

      on_input :left_mouse_button, :on_clicked
      on_input :right_mouse_button, :deselect
    end

    def add(blob)
      @blobs[blob.class] << blob
      case blob
        when Entity
          @entities << blob
        when Projectile
          @projectiles << blob
      end
    end

    def remove(blob)
      @blobs[blob.class].delete blob
      case blob
        when Entity
          @entities.delete blob
        when Projectile
          @projectiles.delete blob
      end
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
      @blobs.each_key do |type|
        type.shader.time = milliseconds / 1000.0
      end

      if @selected && holding?(:left_mouse_button)
        @selected.dragged_to mouse_x, mouse_y
      end

      @entities.each &:update
      @projectiles.each &:update

      perform_collisions
    end

    def perform_collisions
      entities = @entities.dup # These might die before we get anywhere.

      entities.combination 2 do |e1, e2|
        e1.collides_with e2 if e1.touching?(e2)
      end

      @projectiles.dup.each do |p|
        entities.each do |e|
          p.collides_with e if p.touching?(e)
        end
      end
    end

    def draw
      @entities.each &:draw_path_lines

      @blobs.each_pair do |type, blobs|
        type.shader.use do
          blobs.each &:draw
        end
      end
    end
  end
end
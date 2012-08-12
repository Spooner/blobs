module Blobs
  class Projectile < Blob
    DISTANCE = 250

    def initialize(owner, angle, options = {})
      options = {
          speed: 250,
          x: owner.x,
          y: owner.y,
          radius: 8,
          color: Color::GREEN,
          zorder: ZOrder::PROJECTILES,
      }.merge! options

      @owner = owner

      super options

      move_towards x + offset_x(angle, DISTANCE), y + offset_y(angle, DISTANCE)
    end

    def update
      super
      die! unless moving?
    end

    def touching?(other)
      if other == @owner
        false
      else
        super
      end
    end

    def collides_with(other)
      other.die! if self.eats? other
      die!
    end

    def eats?(other)
      other != @owner
    end
  end
end
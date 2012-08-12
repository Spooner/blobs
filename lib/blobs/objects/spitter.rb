require_relative "entity"

# Spits at enemies.
module Blobs
  class Spitter < Entity
    SHOOT_DEVIATION = 10

    def initialize(options = {})
      options = {
          radius: 24,
          speed: 75,
      }.merge! options

      super options

      @time_until_spit = spit_interval
    end

    def spit_interval
      rand 0.2..0.4
    end

    def eats?(other)
      false
    end

    def update
      @time_until_spit -= delta
      spit if @time_until_spit <= 0
      super
    end

    def spit
      shoot_angle = angle + rand(SHOOT_DEVIATION) - rand(SHOOT_DEVIATION)
      Projectile.new self, shoot_angle

      @time_until_spit = spit_interval
    end
  end
end
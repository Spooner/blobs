require_relative "entity"

# Large and slow moving.
module Blobs
  class Eater < Entity
    def initialize(options = {})
      options = {
          radius: 32,
          speed: 50,
      }.merge! options

      super options
    end

    def eats?(other)
      other.is_a?(Darter) || other.is_a?(Spitter)
    end
  end
end
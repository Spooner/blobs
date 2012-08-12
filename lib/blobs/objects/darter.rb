require_relative "entity"

# Small & fast moving.
module Blobs
  class Darter < Entity
    def initialize(options = {})
      options = {
          radius: 16,
          speed: 120,
      }.merge! options

      super options
    end

    def eats?(other)
      other.is_a? Spitter
    end
  end
end
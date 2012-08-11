require_relative "entity"

# Spits at enemies.
module Blobs
  class Spitter < Entity
    def initialize(options = {})
      options = {
          radius: 24,
          speed: 75,
      }.merge! options

      super options
    end
  end
end
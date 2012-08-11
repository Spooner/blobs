require "bundler"
Bundler.require :default

include Gosu
include Chingu

module Blobs
  module ZOrder
    BACKGROUND, MOVE_LINE, ENTITY, SELECTED = *0..100
  end

  class Game < Window
    attr_reader :delta
    def needs_cursor?; true end

    def initialize
      #enable_undocumented_retrofication
      super(800, 600, false)
      @delta = 0
    end

    def update
      $gosu_blocks.clear
      self.caption = "Blobs by Spooner --- FPS: #{fps.to_s}"
      calculate_delta
      super
    end

    def calculate_delta
      @last_update ||= Time.now
      @delta = (Time.now - @last_update).to_f
      @last_update = Time.now
    end

    def setup
      push_game_state Play.new
    end
  end
end

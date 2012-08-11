require_relative "blobs/game"

require_relative "blobs/states/play"

require_relative "blobs/objects/eater"
require_relative "blobs/objects/darter"
require_relative "blobs/objects/spitter"

def fragment_path(name)
  File.expand_path "../blobs/shaders/#{name}.frag", __FILE__
end
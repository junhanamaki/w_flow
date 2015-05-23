module WFlow
  class Node
    def initialize(components, options)
      @components = components
      @options    = options
    end

    def build_node_process(process)
      NodeProcess.new(process, @components, @options)
    end
  end
end
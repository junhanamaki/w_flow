module WFlow
  class Node
    def initialize(components, options)
      @components = components
      @options    = options
    end

    def execute(flow, supervisor, process)
      node_process = NodeProcess.new(@components, @options)

      node_process.execute(flow, supervisor, process)
    end
  end
end
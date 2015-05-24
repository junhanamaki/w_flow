module WFlow
  class Node
    def initialize(components, options)
      @components = components
      @options    = options
    end

    def execute(supervisor, process)
      node_process = NodeProcess.new(@components, @options)

      node_process.execute(supervisor, process)
    end
  end
end
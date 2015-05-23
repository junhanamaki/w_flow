module WFlow
  class Node
    def initialize(components, options)
      @components = components
      @options    = options
    end

    def run(process, flow)
      node_process = NodeProcess.new(@components, @options)

      node_process.run(process, flow)
    end
  end
end
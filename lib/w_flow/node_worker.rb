module WFlow
  class NodeWorker

    def initialize(node_class)
      @node_class = node_class
    end

    def run(workflow)
      if node.around_handler.nil?
        node.components.each do |component|
          if component.is_a?(Class) && component <= Process
            execute_process(component.new(@flow))
          else
            process.wflow_eval(component)
          end
        end
      end
    end

  end
end
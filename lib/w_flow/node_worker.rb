module WFlow
  class NodeWorker

    def initialize(node_class)
      @node_class = node_class
    end

    def init_state(flow)

    end

    def run(workflow)
      # init_state(workflow.flow)

      # if node.around_handler.nil?
      #   node.components.each do |component|
      #     if component.is_a?(Class) && component <= Process
      #       execute_process(component.new(@flow))
      #     else
      #       process.wflow_eval(component)
      #     end
      #   end
      # end
    end

    def finalize
    end

    def rollback
    end

  end
end
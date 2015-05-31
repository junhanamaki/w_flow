module WFlow
  class NodeWorker

    def initialize(node_class, process)
      @node_class = node_class
      @process    = process
    end

    def init_state(flow)
    end

    def run(workflow)
      init_state(workflow.flow)

      if node.around_handler.nil?
        node.components.each do |component|
          if component.is_a?(Class) && component <= Process

            ProcessWorker.new(component).run(workflow)

          else
            process.wflow_eval(component)
          end
        end
      else



      end
    end

    def finalize
    end

    def rollback
    end

  end
end
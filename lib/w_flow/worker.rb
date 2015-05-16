module WFlow
  module Worker
    def initialize(flow)
      @flow = flow
    end

    def start(process_class)
      process = process_class.new(@flow)

      begin
        catch :stop do
          execute_process(@main_process)
        end
      rescue FlowFailure
        # TODO: do rollback
      end

      # TODO: do final
    rescue StandardError => e
      raise if Configuration.raise_errors?

      @failure = { message: e.message, backtrace: e.backtrace }
    end




    def execute_component(component, flow)

    def

    def execute_component_as_process(process_class)
      process = process_class.new(self)

      catch :skip do
        process.setup

        process.nodes.each do |node|
          execute_node(node) if node.execute?(process)
        end

        process.perform
      end
    end

    def execute_node(node)
      stopped = catch :stop do
      end

      node.onStop if stopped
    rescue FlowFailure
      node.onFlowFailure
    end
  end
end
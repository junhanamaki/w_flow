module WFlow
  module Worker
    def initialize(flow)
      @flow         = flow
      @for_final    = []
      @for_rollback = []
    end

    def start(process_class)
      begin
        catch :stop do
          execute_process(process)
        end
      rescue FlowFailure
        # TODO: do rollback
      end

      # TODO: do final
    rescue StandardError => e
      message = { message: e.message, backtrace: e.backtrace }
      flow.failure!(message, silent: true)

      raise unless Configuration.supress_errors?
    end

    def execute_component(component)

    end

  protected

    def execute_process(process_class)
      process = process_class.new(@flow)

      catch :skip do
        process.setup

        @for_final << process

        process.nodes.each do |node|
          execute_node(node) if node.execute?(process)
        end

        process.perform

        @for_rollback << process
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
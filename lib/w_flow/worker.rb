module WFlow
  class Worker
    def initialize(flow)
      @flow            = flow
      @for_final       = []
      @for_rollback    = []
    end

    def start(process_class)
      begin
        catch :stop do
          execute_process(process_class)
        end
      rescue FlowFailure
        @for_rollback.each { |process| process.rollback }
      end

      @for_final.each { |process| process.final }
    rescue ::StandardError => e
      message = { message: e.message, backtrace: e.backtrace }
      @flow.failure!(message, silent: true)

      raise unless Configuration.supress_errors?
    end

    def execute_component(component)
      @current_process
    end

  protected

    def execute_process(process_class)
      ready_process(process_class) do |process|
        catch :skip do
          process.setup

          @for_final << process

          process.nodes.each do |node|
            node.in_context_of(process) do |components|
              components.each do |component|
                execute_component(component)
              end
            end
          end

          process.perform

          @for_rollback << process
        end
      end
    end

    def ready_process(process_class)
      previous_process = @current_process
      @current_process = process_class.new(@flow)

      yield(@current_process)

      @current_process = previous_process
    end
  end
end
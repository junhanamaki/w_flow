module WFlow
  class Flow
    extend Forwardable
    def_delegators :@report, :success?, :failure?

    attr_reader :data

    def initialize(params)
      @data    = Data.new(params)
      @report  = Report.new(@data)
      @backlog = []
      @to_rollback = []
      @to_finalize = []
    end

    def start(process_class)
      execute_main_process(process_class.new(self))

      @report
    end

    def skip!; throw :skip, true; end
    def stop!; throw :stop, true; end

    def failure!(message = nil)
      @report.failure!(message)

      raise FlowFailure
    end

  protected

    def execute_main_process(process)
      in_context_of(process) do
        begin
          catch :stop do
            catch :skip do
              execute_process_flow(process)
            end
          end
        rescue FlowFailure
          do_rollback
        end

        do_finalize
      end
    rescue ::StandardError => e
      @report.failure!(message: e.message, backtrace: e.backtrace)

      raise unless Configuration.supress_errors?
    end

    def execute_process_flow(process)
      process.setup

      process.wflow_nodes.each do |node|

      end

      process.perform
    end

    def execute_node_flow(node)
    end

    def in_context_of(supervisable)
      @backlog     << @currently_supervising unless @currently_supervising.nil?
      @to_finalize << supervisable
      @currently_supervising = supervisable

      yield

      @to_rollback << supervisable
      @currently_supervising = @backlog.pop
    end

    def do_rollback
      @to_rollback.each(&:rollback)
    end

    def do_finalize
      @to_finalize.each(&:finalize)
    end
  end
end
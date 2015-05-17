module WFlow
  class Flow
    extend Forwardable
    def_delegators :@report, :success?, :failure?
    def_delegator  :@report, :failure_message, :message

    attr_reader :data

    def initialize(data)
      @data   = Data.new(data)
      @report = Report.new

      @processes_backlog      = []
      @processes_for_rollback = []
      @processes_for_finalize = []
    end

    def supervise(process)
      in_context_of(process) do
        begin
          stopped = catch :stop do
            catch :skip do
              yield
            end
          end

          stop! if !!stopped && !parent_process? && process.on_stop
        rescue FlowFailure
          raise if !parent_process? && process.on_failure
        end

        finalize_processes if parent_process?
      end
    rescue ::StandardError => e
      @report.register_failure(message: e.message, backtrace: e.backtrace)

      raise unless Configuration.supress_errors?
    end

    def failure!(message = nil)
      @report.register_failure(message)

      raise FlowFailure
    end

    def stop!
      throw :stop, true
    end

    def skip!
      throw :skip, true
    end

  protected

    def parent_process?
      @processes_backlog.empty?
    end

    def in_context_of(process)
      @processes_backlog << @current_process unless @current_process.nil?
      @current_process = process

      yield

      @current_process = @processes_backlog.pop
    end

    def rollback_processes
      @processes_to_rollback.each(&:rollback)
    end

    def finalize_processes
      @processes_to_finalize.each(&:finalize)
      end
    end
  end
end
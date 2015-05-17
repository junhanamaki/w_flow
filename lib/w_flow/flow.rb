module WFlow
  class Flow
    extend Forwardable
    def_delegators :@report, :success?, :failure?
    def_delegator  :@report, :failure_message, :message

    attr_reader :data

    def initialize(data)
      @data    = Data.new(data)
      @report  = Report.new
      @backlog = []
      @to_rollback = []
      @to_finalize = []
    end

    def supervise_process(process)
      in_context_of(process) do
        if main_process?
          begin
            catch :stop do
              catch :skip do
                yield
              end
            end
          rescue FlowFailure
            rollback_processes
          end

          finalize_processes
        else
          yield
        end
      end
    rescue ::StandardError => e
      @report.register_failure(message: e.message, backtrace: e.backtrace)

      raise unless Configuration.supress_errors?
    end

    def supervise_node(handlers)
      yield
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

    def main_process?
      @backlog.empty?
    end

    def in_context_of(process)
      @backlog << @current_process unless @current_process.nil?

      @current_process = process

      yield

      @current_process = @backlog.pop
    end

    def rollback_processes
      @to_rollback.each(&:rollback)
    end

    def finalize_processes
      @to_finalize.each(&:finalize)
    end
  end
end
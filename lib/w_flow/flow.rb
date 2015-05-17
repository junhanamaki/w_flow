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

    def supervise(process, handlers)
      in_context_of(process, handlers) do
        begin
          stopped = catch :stop do
            catch :skip do
              yield
            end
          end

          stop! if stopped && rethrow_stop?
        rescue FlowFailure
          raise if reraise_flow_failure?
        end

        finalize_processes if main_process?
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

    def rethrow_stop?
      !main_process? && current_handler_call(:stop)
    end

    def reraise_flow_failure?
      !main_process? && current_handler_call(:failure)
    end

    def main_process?
      @backlog.empty?
    end

    def in_context_of(process, handlers)
      @backlog << @current_context unless @current_context.nil?

      @current_context = { process: process, handlers: handlers }

      yield

      @current_context = @backlog.pop
    end

    def current_handler_call(name)
      !@current_context[:handlers][name].nil? &&
      @current_context[:handlers][name].call
    end

    def rollback_processes
      @to_rollback.each(&:rollback)
    end

    def finalize_processes
      @to_finalize.each(&:finalize)
      end
    end
  end
end
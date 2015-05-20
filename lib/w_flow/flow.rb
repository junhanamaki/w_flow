module WFlow
  class Flow
    extend Forwardable
    def_delegators :@report, :success?, :failure?

    attr_reader :data

    def initialize(data)
      @data    = Data.new(data)
      @report  = Report.new(@data)
      @backlog = []
      @to_rollback = []
      @to_finalize = []
    end

    def supervise(supervisable)
      in_context_of(supervisable) do
        if main_process?
          begin
            catch :stop do
              catch :skip do
                yield
              end
            end
          rescue FlowFailure
            do_rollback
          end

          do_finalize
        else
          yield
        end
      end
    rescue ::StandardError => e
      @report.register_failure(message: e.message, backtrace: e.backtrace)

      raise unless Configuration.supress_errors?
    end

    def failure!(message = nil)
      @report.failure!(message)

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

    def in_context_of(supervisable)
      @backlog << @current_supervisable unless @current_supervisable.nil?

      @current_supervisable = supervisable

      yield

      @current_supervisable = @backlog.pop
    end

    def do_rollback
      @to_rollback.each(&:rollback)
    end

    def do_finalize
      @to_finalize.each(&:finalize)
    end
  end
end
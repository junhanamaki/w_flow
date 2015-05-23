module WFlow
  class Flow
    extend Forwardable
    def_delegators :@report, :success?, :failure?

    attr_reader :data, :report

    def initialize(params)
      @data    = Data.new(params)
      @report  = Report.new(@data)
      @backlog = []
      @to_rollback = []
      @to_finalize = []
    end

    def supervise(supervisable)
      in_context_of(supervisable) do
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
      end
    rescue ::StandardError => e
      raise unless Configuration.supress_errors?

      @report.failure!(message: e.message, backtrace: e.backtrace)
    end

    def skip!; throw :skip, true; end
    def stop!; throw :stop, true; end

    def failure!(message = nil)
      @report.failure!(message)

      raise FlowFailure
    end

  protected

    def in_context_of(supervisable)
      @backlog     << @current_supervisable unless @current_supervisable.nil?
      @to_finalize << supervisable
      @current_supervisable = supervisable

      yield

      @to_rollback << supervisable
      @current_supervisable = @backlog.pop
    end

    def do_rollback; @to_rollback.each(&:rollback); end
    def do_finalize; @to_finalize.each(&:finalize); end
  end
end
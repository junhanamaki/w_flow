module WFlow
  class Flow
    extend Forwardable
    def_delegators :@report, :success?, :failure?

    attr_reader :data, :report

    def initialize(params)
      @data    = Data.new(params)
      @report  = Report.new(@data)
      @backlog = []
    end

    def executing(supervisable)
      in_context_of(supervisable) do
        begin
          catch :stop do
            catch :skip do
              yield
            end
          end
        rescue FlowFailure
        end

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
      @current_supervisable = supervisable

      yield

      @current_supervisable = @backlog.pop
    end
  end
end
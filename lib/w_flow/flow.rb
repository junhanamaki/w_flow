module WFlow
  class Flow
    extend Forwardable
    def_delegators :@report, :success?, :failure?
    def_delegator  :@report, :failure_message, :message

    attr_reader :data

    def initialize(data)
      @data   = Data.new(data)
      @report = Report.new
    end

    def supervise_process(process, on_stop = nil, on_failure = nil)
      if initial_process?
        in_context_of(process) do
          begin
            catch :stop do
              catch :skip do
                yield
              end
            end
          rescue FlowFailure
            # rollback
          end

          # final
        end
      else
        in_context_of(process) do
          stopped = catch :stop
            skipped = catch :skip do
            end
          end
        end
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

    def execute!(component)
    end

  protected

    def initial_process?
      @current_process.nil?
    end

    def in_context_of(process)
      previous_process = @current_process
      @current_process = process

      yield

      @current_process = previous_process
    end
  end
end
module WFlow
  class Flow
    attr_reader :data, :message

    def initialize(data)
      @data    = data
      @failure = false
      @message = nil
      @backlog = []
    end

    def executing(executable)
      in_context_of(executable) do
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

      failure!(message: e.message, backtrace: e.backtrace) rescue nil
    end

    def success?
      !failure?
    end

    def failure?
      @failure
    end

    def skip!; throw :skip, true; end
    def stop!; throw :stop, true; end

    def failure!(message = nil)
      @failure = true
      @message = message

      raise FlowFailure
    end

  protected

    def in_context_of(executable)
      @backlog << @current_executable unless @current_executable.nil?
      @current_executable = executable

      yield

      @current_executable = @backlog.pop
    end
  end
end
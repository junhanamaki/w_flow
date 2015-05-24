module WFlow
  class Flow
    attr_reader :data, :message

    def initialize(params)
      @data    = Data.new(params)
      @failure = false
      @message = nil
      @backlog = []
    end

    def executing(process, &block)
      in_context_of(process) do
        if parent_process_context?
          executing_parent_process(&block)
        else
          executing_child_process(&block)
        end
      end
    end

    def terminated?; @current_process.nil?; end

    def success?; !failure?; end
    def failure?; @failure;  end

    def skip!; throw :skip, true; end
    def stop!; throw :stop, true; end

    def failure!(message = nil)
      @failure = true
      @message = message

      raise FlowFailure
    end

  protected

    def parent_process_context?
      @backlog.empty?
    end

    def executing_parent_process
      catch :stop do
        catch :skip do
          yield
        end
      end
    rescue FlowFailure
    rescue ::StandardError => e
      raise unless Configuration.supress_errors?

      failure!(message: e.message, backtrace: e.backtrace) rescue nil
    end

    def executing_child_process
      stopped = catch :stop do
        catch :skip do
          yield
        end
      end

      stop! if stopped && !cancel_stop?
    rescue FlowFailure
      raise if !cancel_failure?
    end

    def cancel_stop?
      @current_process.cancel_stop?
    end

    def cancel_failure?
      @current_process.cancel_failure?
    end

    def in_context_of(process)
      @backlog << @current_process unless @current_process.nil?
      @current_process = process

      yield

      @current_process = @backlog.pop
    end
  end
end
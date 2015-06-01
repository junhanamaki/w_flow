module WFlow
  module Supervisor

    @succeeded = SupervisorReport.new
    @skipped   = SupervisorReport.new(:skip)
    @stopped   = SupervisorReport.new(:stop)

    class << self

      def supervise
        catch :wflow_interrupt do
          yield

          @succeeded
        end
      end

      def signal_skip!
        throw :wflow_interrupt, @skipped
      end

      def signal_stop!
        throw :wflow_interrupt, @stopped
      end

      def signal_failure!(message = nil)
        throw :wflow_interrupt, SupervisorReport.new(:failure, message)
      end

      def resignal!(report)
        throw :wflow_interrupt, report
      end

    end

  end
end
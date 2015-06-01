module WFlow
  class WorkflowReport

    extend Forwardable
    def_delegators :@workflow, :data, :success?, :failure?, :failure_log

    def initialize(workflow)
      @workflow = workflow
    end

  end
end
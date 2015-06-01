require "w_flow/version"
require "w_flow/configuration"
require "w_flow/data"
require "w_flow/supervisor_report"
require "w_flow/supervisor"
require "w_flow/flow"
require "w_flow/node"
require "w_flow/node_worker"
require "w_flow/process"
require "w_flow/process_worker"
require "w_flow/workflow"
require "w_flow/workflow_report"

module WFlow

  # WFlow errors
  class StandardError < ::StandardError; end

  class InvalidArguments < StandardError; end
  class FlowFailure      < StandardError; end
  class InvalidOperation < StandardError; end

  # WFlow message constants
  INVALID_RUN_PARAMS = "run must be invoked without arguments or an Hash"
  UNKNOWN_EXPRESSION = "can't evaluate expression"
  INVALID_OPERATION  = "skip!, stop! or failure! can't be invoked during finalize/rollback"

end

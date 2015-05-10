module WFlow
  class StandardError < ::StandardError; end

  class InvalidArgument < StandardError; end
  class FlowFailure < StandardError; end
  class UnknownTask < StandardError; end
end
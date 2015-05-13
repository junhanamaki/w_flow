module WFlow
  class StandardError < ::StandardError; end

  class InvalidArgument < StandardError; end
  class UnknownNodeElement < StandardError; end
  class FlowFailure < StandardError; end
end
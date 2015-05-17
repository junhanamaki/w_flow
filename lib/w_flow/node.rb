module WFlow
  class Node
    def initialize(owner_process, flow, components, options = {})
      @components = components
      @options    = options
    end

    def run
    end

  protected

    def execute?
      allowed_by_if_option? && allowed_by_unless_option?
    end

    def allowed_by_if_option?
      @options[:if].nil? || process.expression_eval(@options[:if])
    end

    def allowed_by_unless_option?
      @options[:unless].nil? || !process.expression_eval(@options[:unless])
    end
  end
end
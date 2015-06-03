module WFlow
  class Node

    class << self

      attr_reader :tasks, :options

      def build(tasks, options)
        Class.new(self) do |klass|
          @tasks   = tasks
          @options = options
        end
      end

    end

  end
end
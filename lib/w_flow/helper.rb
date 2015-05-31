module WFlow
  module Helper
    class << self
      def object_eval(supervisor, process, object, *args)
        if object <= Process
          object.new.wflow_execute(supervisor, *args)
        else
          process.wflow_eval(object, *args)
        end
      end
    end
  end
end
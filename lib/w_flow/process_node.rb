module WFlow
  class ProcessNode
    def initialize(tasks, options)
      @tasks   = tasks
      @options = options
    end

    def execute(owner_process)
      return unless execute_node?(owner_process)

      @tasks.each do |task|
        if task.is_a?(String) || task.is_a?(Symbol)
          owner_process.instance_eval(task.to_s)
        elsif task.is_a?(Proc)
          owner_process.instance_eval(&task)
        elsif task == Process
          task.run_as_task(owner_process.flow)
        else
          raise UnknownTask, "don't know how to execute task #{task}"
        end
      end
    end

  protected

    def execute_node?(owner_process)
      allowed_by_if_condition?(owner_process) &&
      allowed_by_unless_condition?(owner_process)
    end

    def allowed_by_if_condition?(owner_process)
      @options[:if].nil? || eval_condition(@options[:if], owner_process)
    end

    def allowed_by_unless_condition?(owner_process)
      @options[:unless].nil? || !eval_condition(@options[:unless], owner_process)
    end

    def eval_condition(condition, owner_process)
      ((condition.is_a?(String) || condition.is_a?(Symbol)) &&
       owner_process.instance_eval(condition.to_s)) ||
      (condition.is_a?(Proc) && owner_process.instance_eval(&condition))
    end
  end
end
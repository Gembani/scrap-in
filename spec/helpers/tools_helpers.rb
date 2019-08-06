module ToolsHelpers
  def disable_puts_for_class(class_name)
    class_name.constantize if class_name.class.name == 'String'
    allow_any_instance_of(class_name).to receive(:puts)
  end
end
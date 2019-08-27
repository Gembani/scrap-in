module ToolsHelpers
  def disable_puts_for_class(class_name)
    allow_any_instance_of(described_class).to receive(:puts)
  end

  def disable_method(name)
    name.to_s if name.class.name == 'String'
    allow_any_instance_of(described_class).to receive(name)
  end

  def disable_sleep_for_class(class_name)
    allow_any_instance_of(class_name).to receive(:sleep)
  end
end

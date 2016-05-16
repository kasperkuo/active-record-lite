class AttrAccessorObject
  def self.my_attr_accessor(*names)


    names.each do |name|
      define_method(name) do
        ivar_name = "@#{name}"
        instance_variable_get(ivar_name)
      end
      #
      define_method("#{name}=") do |arg|
        ivar_name = "@#{name}"
        instance_variable_set(ivar_name, arg)
      end

    end
    # ...
  end
end

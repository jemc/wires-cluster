
# For now, must require in this order
# to avoid active_support wrecking json/add/core
require 'active_support/json'
require 'json/add/core'


# Define default JSON behavior for objects as UnserializableObject
class Object
  def as_json(opt=nil)
    UnserializableObject.new.as_json
  end
  
  def self.json_create(data)
    UnserializableObject.new
  end
end

# A placeholder object to alert the JSON receiver that 
# the intended object has no defined serialization scheme
class UnserializableObject
  def to_s; '<UnserializableObject>'; end
  def inspect; to_s; end
  
  def as_json(opt=nil)
    { json_class:self.class.name }
  end
  
  def self.json_create(data)
    self.new
  end
end


# Define a serialization scheme for Wires Events
class Wires::Event
  def as_json(*serialization_args)
    { json_class:self.class.name,
      args:[*@args, **@kwargs] }
  end
  
  def self.json_create(data)
    self.new(*data['args'])
  end
end

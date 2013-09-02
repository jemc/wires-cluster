
# For now, must require in this order
# to avoid active_support wrecking json/add/core
require 'active_support/json'
require 'json/add/core'

# Add for reference when parsing for incomplete packets
require 'json/pure/parser'


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


# Add JSON-related functions to Wires::Cluster
module Wires
  module Cluster
    class << self
      
      # Perform rudimentary JSON verification to make sure str is not 
      #   a partial payload due to missing or yet-to-come packets,
      #   then actually load in the JSON objects and return them
      def _load_json(str)
        ref_parser = JSON::Pure::Parser
        
        # Ignore json comments and strings for open/close count verification
        stripped_str = str.gsub(ref_parser::IGNORE, '')
                        .gsub(ref_parser::STRING, '')
        
        # Missing tail if any quote symbols remain after string purge
        raise JSON::MissingTailError if stripped_str.match /(?<!\\)"/
        
        # Make sure open/close symbol counts match
        [[ref_parser::OBJECT_OPEN, ref_parser::OBJECT_CLOSE],
         [ref_parser::ARRAY_OPEN,  ref_parser::ARRAY_CLOSE]].each do |a, z|
          case (stripped_str.scan(a).size) <=> (stripped_str.scan(z).size)
          when  1; raise JSON::MissingTailError
          when -1; raise JSON::MissingHeadError
          end
        end
        
        # Try to load objects from the string and return the result
        JSON.load(str)
      end; private :_load_json
      
    end
  end
end

class JSON::MissingTailError < JSON::ParserError; end
class JSON::MissingHeadError < JSON::ParserError; end
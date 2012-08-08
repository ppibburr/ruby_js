=begin
  *
    Make patches to normalize the subclassing of GObjects
  *
=end

class Object
  # alias the original allocate and new class methods
  class << self
    alias :_alloc_ :allocate
    alias :_new_ :new
  end
end

module GObject
  class Object
    # accessor :enable_auto_subclass_normalize, true by default
    class << self
      attr_accessor :enable_auto_subclass_normalize
    end
    @enable_auto_subclass_normalize = true
    
    @@instances = {}
    
    # retrieve the pointer.address <--> object.object_id store
    def self._instances
      @@instances
    end
  
    class << self
      alias _wrap wrap
    end
  
    # Maintains|Appends|Modifies a store of addresses and object_id's
    # Maps new occurances
    # Retrieves previous occurances
    #
    # so ...
    #    object.signal_connect "signal-name" do |i_am_object|
    #      (i_am_object == object) #=> true
    #    end
    #
    def self.wrap ptr
      return nil if ptr.nil? or ptr.null?
      
      if id =_instances[ptr.address]
        obj = ObjectSpace._id2ref(id)
      else
        obj = super(ptr)
        _instances[ptr.address] = obj.object_id
      end
      
      return obj
    end

    # if enabled, removes the explicit need to call subclass! in a class definition
    def self.inherited cls
      result = super
      
      return result unless GObject::Object.enable_auto_subclass_normalize
      sn= cls.gir_info.safe_name
      ns= cls.gir_info.namespace
      
      if cls.name and  ns+"::"+sn != cls.name and !cls.name.empty?
        cls.subclass!
      end
    end
    
    # Sets up normal initializing on a subclass
    def self.subclass!
      # revert to Object.new and its allocation/initializing chain
      def self.new *o
        _new_ *o
      end
      
      
      def self.gtype
        superclass 
      end
      
      include GObject::Quux
    end
  end
  
  # Module to enable normal subclassing
  module Quux
    # establishes normal subclassing calls to super()
    # arguments passed will be sent to aSomeGType = SomeGType.new *o
    # sets @struct to the, instance of aSomeGType's, @struct,
    #   so self.to_ptr will work, enabling methods defined by the type in initialize
    #
    # replaces the object_id corresponding to the pointer.address to be that of self
    #   versus the aSomeGtype
    def initialize *o
      obj = self.class.gtype.new(*o)
      @struct = obj.instance_variable_get(:@struct)
      self.class._instances[obj.to_ptr.address] = self.object_id
      super()
    end
  end
end

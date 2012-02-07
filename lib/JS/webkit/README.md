Class: WebKit::GLibProvider

The base cass of all objects in the WebKit namespace

Holds the reference from an FFI::Pointer in a property
  and delegates to the object returned from get_property!('real')
  as this setups signals and such

Instances of this class delegate the methods: get_property, signal_connect
  to the providee

Subclasses of this class delegate the methods :signal, :signals, :property, :properties
  to providee.class
  
  To use the methods from above on GLibProvider instance or subclass
  suffix the above methods with ! ie, WebKit::WebView.properties! #=> ["real"]

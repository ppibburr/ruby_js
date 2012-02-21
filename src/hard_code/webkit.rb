
begin
  require File.join(File.dirname(__FILE__),'webkit_ffi')
rescue LoadError
  require File.join(File.dirname(__FILE__),'webkit_gir_ffi')
end

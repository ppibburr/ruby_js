require 'gir_ffi'
GirFFI.setup(:Gtk,'2.0')
require File.join(File.dirname(__FILE__),'patch_gtk_gir_ffi')
GirFFI.setup :WebKit,'1.0'
require File.join(File.dirname(__FILE__),'patch_gir_ffi_webkit')

window.make_new = function() {
  var string,
      shift = Array.prototype.shift;
  string = shift.call(arguments);
  klass = window[string]
  // Create an object that extends the target prototype.
  var new_made = Object.create( klass.prototype );
 
  // Invoke the custom constructor on the new object,
  // passing in any arguments that were provided.
  new_made = (klass.apply( new_made, arguments ) || new_made);
 
  // Return the newly created friend.
  return( new_made );
}

window.setValue = function(cm,val) {
	cm.setValue("ggg");
	return 1;
}
window.connect = function(w,s,f) {
	CodeMirror.connect(w,s,f);
	return true;
}

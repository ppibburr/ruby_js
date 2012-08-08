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

xui.extend({
   fade:function(to, callback) {
       var target = 0;
       if (typeof to == 'string' && to == 'in') target = 1;
       else if (typeof to == 'number') target = to;
       return this.tween({opacity:target,duration:.2}, callback);
   }, 

	/**
	 * Adds more DOM nodes to the existing element list.
	 */
	add: function(q) {
	  [].push.apply(this, slice(xui(q)));
	  return this.set(this.reduce());
	},

	/**
	 * Pops the last selector from XUI
	 */
	end: function () {	
		return this.set(this.cache || []);	 	
	},
  /**
   * Sets the `display` CSS property to `block`.
   */
  show:function() {
    return this.setStyle('display','block');
  },
  /**
   * Sets the `display` CSS property to `none`.
   */
  hide:function() {
    return this.setStyle('display','none');
  }
});

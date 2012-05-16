function rwt_widget_create(parent,tag,bool) {
	ele = document.createElement(tag);
	if (bool==true) {
		parent.appendChild(ele);
	}
	return ele;
};
function rwt_object_add_event(obj,event,func) {
	obj.addEventListener(event,func,false);
	return(null);
};
function rwt_object_clone(ele,bool) {
  return ele.cloneNode(bool);	
};
function rwt_widget_clone_create(parent,ele,bool) {
  var clone = rwt_object_clone(ele,bool);
  parent.appendChild(clone);
  return(clone);
};
function times_do(amt,closure) {
  var i=0;
  for (i=0;i<=amt;i++)
  {
    closure.call(null,i);
  };
};

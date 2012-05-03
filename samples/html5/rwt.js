function rwt_widget_create(parent,tag,bool) {
	ele = document.createElement(tag);
	if (bool==true) {
		parent.appendChild(ele);
	}
	return ele;
};
function rwt_object_add_event(obj,event,func) {
	obj.addEventListener(event,func);
};

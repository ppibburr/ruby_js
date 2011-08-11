/*!
@function
@abstract Retains a JavaScript property name array.
@param array The JSPropertyNameArray to retain.
@result A JSPropertyNameArray that is the same as array.
*/
JS_EXPORT JSPropertyNameArrayRef JSPropertyNameArrayRetain(JSPropertyNameArrayRef array);

/*!
@function
@abstract Releases a JavaScript property name array.
@param array The JSPropetyNameArray to release.
*/
JS_EXPORT void JSPropertyNameArrayRelease(JSPropertyNameArrayRef array);

/*!
@function
@abstract Gets a count of the number of items in a JavaScript property name array.
@param array The array from which to retrieve the count.
@result An integer count of the number of names in array.
*/
JS_EXPORT size_t JSPropertyNameArrayGetCount(JSPropertyNameArrayRef array);

/*!
@function
@abstract Gets a property name at a given index in a JavaScript property name array.
@param array The array from which to retrieve the property name.
@param index The index of the property name to retrieve.
@result A JSStringRef containing the property name.
*/
JS_EXPORT JSStringRef JSPropertyNameArrayGetNameAtIndex(JSPropertyNameArrayRef array, size_t index);



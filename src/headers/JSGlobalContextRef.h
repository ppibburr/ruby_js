/*!
@function
@abstract Creates a global JavaScript execution context.
@discussion JSGlobalContextCreate allocates a global object and populates it with all the
 built-in JavaScript objects, such as Object, Function, String, and Array.

 In WebKit version 4.0 and later, the context is created in a unique context group.
 Therefore, scripts may execute in it concurrently with scripts executing in other contexts.
 However, you may not use values created in the context in other contexts.
@param globalObjectClass The class to use when creating the global object. Pass 
 NULL to use the default object class.
@result A JSGlobalContext with a global object of class globalObjectClass.
*/
JS_EXPORT JSGlobalContextRef JSGlobalContextCreate(JSClassRef globalObjectClass);

/*!
@function
@abstract Creates a global JavaScript execution context in the context group provided.
@discussion JSGlobalContextCreateInGroup allocates a global object and populates it with
 all the built-in JavaScript objects, such as Object, Function, String, and Array.
@param globalObjectClass The class to use when creating the global object. Pass
 NULL to use the default object class.
@param group The context group to use. The created global context retains the group.
 Pass NULL to create a unique group for the context.
@result A JSGlobalContext with a global object of class globalObjectClass and a context
 group equal to group.
*/
JS_EXPORT JSGlobalContextRef JSGlobalContextCreateInGroup(JSContextGroupRef group, JSClassRef globalObjectClass);

/*!
@function
@abstract Retains a global JavaScript execution context.
@param ctx The JSGlobalContext to retain.
@result A JSGlobalContext that is the same as ctx.
*/
JS_EXPORT JSGlobalContextRef JSGlobalContextRetain(JSGlobalContextRef ctx);

/*!
@function
@abstract Releases a global JavaScript execution context.
@param ctx The JSGlobalContext to release.
*/
JS_EXPORT void JSGlobalContextRelease(JSGlobalContextRef ctx);

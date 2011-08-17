#include <JavaScriptCore/JavaScript.h>


JSClassDefinition* 
JSRubyObjectClass() {
  static JSClassDefinition definition;
  memset(&definition,0,sizeof(definition));
  definition.version = 0;
  return &definition;
}

void 
JSRubyObjectClassSetGetPropertyCallback(JSClassDefinition* definition,JSObjectGetPropertyCallback callback) {

    definition->getProperty = callback;
}

void 
JSRubyObjectClassSetSetPropertyCallback(JSClassDefinition* definition,JSObjectSetPropertyCallback callback) {

    definition->setProperty = callback;
}

void 
JSRubyObjectClassSetHasPropertyCallback(JSClassDefinition* definition,JSObjectHasPropertyCallback callback) {

    definition->hasProperty = callback;
}

int
 main() {
  return 1;
}


//       JSRubyObjectClass.c
             
//		(The MIT License)
//
//        Copyright 2011 Matt Mesanko <tulnor@linuxwaves.com>
//
//		Permission is hereby granted, free of charge, to any person obtaining
//		a copy of this software and associated documentation files (the
//		'Software'), to deal in the Software without restriction, including
//		without limitation the rights to use, copy, modify, merge, publish,
//		distribute, sublicense, and/or sell copies of the Software, and to
//		permit persons to whom the Software is furnished to do so, subject to
//		the following conditions:
//
//		The above copyright notice and this permission notice shall be
//		included in all copies or substantial portions of the Software.
//
//		THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
//		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// 
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

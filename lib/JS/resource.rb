
#       resource.rb
             
#		(The MIT License)
#
#        Copyright 2011 Matt Mesanko <tulnor@linuxwaves.com>
#
#		Permission is hereby granted, free of charge, to any person obtaining
#		a copy of this software and associated documentation files (the
#		'Software'), to deal in the Software without restriction, including
#		without limitation the rights to use, copy, modify, merge, publish,
#		distribute, sublicense, and/or sell copies of the Software, and to
#		permit persons to whom the Software is furnished to do so, subject to
#		the following conditions:
#
#		The above copyright notice and this permission notice shall be
#		included in all copies or substantial portions of the Software.
#
#		THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
#		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
module JS
  module Resource
    def self.load_script ctx,path,this = nil
      JS.execute_script(ctx,open(path).read,this)
    end
    
    def self.eval_script ctx,string,this=nil
      JS.execute_script(ctx,string,this)    
    end
    
    def self.eval_style document,string
      styleNode = document.createElement('style');
      styleNode.type = "text/css";
      styleText = document.createTextNode(string);
      styleNode.appendChild(styleText);
      document.getElementsByTagName('head')[0].appendChild(styleNode);    
    end
    
    def self.load_link document,uri
		link = document.createElement('link')
		link.setAttribute('rel','StyleSheet')
		link.setAttribute('type','text/css')
		link.setAttribute('href',uri)
		link.setAttribute('media','screen')
		document.getElementsByTagName('body')[0].appendChild link    
    end
  end
end

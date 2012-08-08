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

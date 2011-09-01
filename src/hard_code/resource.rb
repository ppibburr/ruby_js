module JS
  module Script
    def self.load ctx,path,this = nil
      JS.execute_script(ctx,File.read(path),this)
    end
  end
  
  module Style
    def self.load document,path
      load_string File.read(path);
    end
    
    def self.load_string document,string
      styleNode = document.createElement('style');
      styleNode.type = "text/css";
      styleText = document.createTextNode(string);
      styleNode.appendChild(styleText);
      document.getElementsByTagName('head')[0].appendChild(styleNode);     
    end
  end
end

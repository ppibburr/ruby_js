module JS
  module Script
    def self.load ctx,path,this = nil
      JS.execute_script(ctx,File.read(path),this)
    end
  end
  
  module Style
    def self.load document,path
     styleNode = document.createElement('style');
     styleNode.type = "text/css";
     styleText = document.createTextNode(File.read(path));
     styleNode.appendChild(styleText);
     document.getElementsByTagName('head')[0].appendChild(styleNode);    
    end
  end
end

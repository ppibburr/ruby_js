module Rwt
  module UI
    class Expander
      attr_reader :toggler,:expandee
      def initialize t,e
        @expandee = e
        @toggler = t
        
        Rwt::UI::Collection.new(nil,[@toggler]).on('click') do
          toggle()
        end
      end
      
      def toggle
        if @_shaded
          @expandee.style['height'] = @_shaded
          @_shaded = false
        else
          @_shaded = Rwt::UI::Collection.new(nil,[@expandee])[0].get_css_style('height')
          @expandee.style['height'] = @toggler.clientHeight.to_s+"px"          
        end
      end
      
      def shaded?
        !!@_shaded
      end
    end
  end
end

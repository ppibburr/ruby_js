
#       html5_dom_builder.rb
             
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
  module DOM
    class Builder
      TAGS = %w[<a>
<abbr>
<address>
<area>
<article>
<aside>
<audio>
<b>
<base>
<bb>
<bdo>
<blockquote>
<body>
<br>
<button>
<canvas>
<caption>
<cite>
<code>
<col>
<colgroup>
<command>
<datagrid>
<datalist>
<dd>
<del>
<details>
<dfn>
<div>
<dl>
<dt>
<em>
<embed>
<eventsource>
<fieldset>
<figcaption>
<figure>
<footer>
<form>
<h1>
<h2>
<h3>
<h4>
<h5>
<h6>
<head>
<header>
<hgroup>
<hr>
<html>
<i>
<iframe>
<img>
<input>
<ins>
<kbd>
<keygen>
<label>
<legend>
<li>
<link>
<mark>
<map>
<menu>
<meta>
<meter>
<nav>
<noscript>
<object>
<ol>
<optgroup>
<option>
<output>
<p>
<param>
<pre>
<progress>
<q>
<ruby>
<rp>
<rt>
<samp>
<script>
<section>
<select>
<small>
<source>
<span>
<strong>
<style>
<sub>
<summary>
<sup>
<table>
<tbody>
<td>
<textarea>
<tfoot>
<th>
<thead>
<time>
<title>
<tr>
<ul>
<var>
<video>
<wbr>]
      def initialize obj,parent = nil
        @global = obj
        @document = obj.document
        @parent = parent||@document.getElementsByTagName('html')[0]
        @data = {}
      end
      
      def build &b
        instance_eval &b
      end
      
      def add_data sym,o
        @data[sym] = o
      end
      
      def self.build obj,parent=nil,&b
        self.new(obj,parent).build &b
      end
      
      def inner_html str
        @parent.innerHTML = str
      end
      
      def outer_html str
        @parent.outerHTML = str
      end
 
      def inner_text str
        @parent.innerText = str
      end 
      
      def style
        @parent.style
      end
      
      alias :text :inner_text
      alias :html :inner_html
      
      def method_missing m,*o,&b;
        if @data[m]
          exit
          return @data[m]
        end
        if m.to_s =~ /^on/
          return @parent[m.to_s] = b
        end
        
        if !TAGS.map do |t| t.gsub("<",'').gsub(">",'') end.index(m.to_s)
          begin
            return @parent.send(m,*o,&b)
          rescue
            return @global.send(m,*o,&b)
          end
        end
        
        ar = o[0]||{}
        
        raise "Expected Hash but got #{ar.class}" unless ar.respond_to?(:each_pair)
        
        @ele = @document.createElement(m.to_s)
        @parent.appendChild @ele
        
        ar.each_pair do |k,v|
          @ele.setAttribute k.to_s,v
        end
        
        if block_given?
          Builder.build(@global,@ele, &b)
        end
        
        @ele
      end 
    end
  end
end

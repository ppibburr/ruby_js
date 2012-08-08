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

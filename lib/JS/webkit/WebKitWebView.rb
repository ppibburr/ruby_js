module WebKit
  class WebKit::WebView < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_view_get_type(self)
    end


    # returns:  -> string
    def get_title()
      r = Lib.webkit_web_view_get_title(self)
    end


    # returns:  -> string
    def get_uri()
      r = Lib.webkit_web_view_get_uri(self)
    end


    # flag_ -> 
    # returns:  -> void
    def set_maintains_back_forward_list(flag_)
      r = Lib.webkit_web_view_set_maintains_back_forward_list(self,flag_)
    end


    # returns:  -> pointer
    def get_back_forward_list()
      r = Lib.webkit_web_view_get_back_forward_list(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # item_ -> 
    # returns:  -> bool
    def go_to_back_forward_item(item_)
      begin; item_ = RGI.rval2gobj(item_); rescue; end
      r = Lib.webkit_web_view_go_to_back_forward_item(self,item_)
    end


    # returns:  -> bool
    def can_go_back()
      r = Lib.webkit_web_view_can_go_back(self)
    end


    # steps_ -> 
    # returns:  -> bool
    def can_go_back_or_forward(steps_)
      r = Lib.webkit_web_view_can_go_back_or_forward(self,steps_)
    end


    # returns:  -> bool
    def can_go_forward()
      r = Lib.webkit_web_view_can_go_forward(self)
    end


    # returns:  -> void
    def go_back()
      r = Lib.webkit_web_view_go_back(self)
    end


    # steps_ -> 
    # returns:  -> void
    def go_back_or_forward(steps_)
      r = Lib.webkit_web_view_go_back_or_forward(self,steps_)
    end


    # returns:  -> void
    def go_forward()
      r = Lib.webkit_web_view_go_forward(self)
    end


    # returns:  -> void
    def stop_loading()
      r = Lib.webkit_web_view_stop_loading(self)
    end


    # uri_ -> 
    # returns:  -> void
    def open(uri_)
      r = Lib.webkit_web_view_open(self,uri_)
    end


    # returns:  -> void
    def reload()
      r = Lib.webkit_web_view_reload(self)
    end


    # returns:  -> void
    def reload_bypass_cache()
      r = Lib.webkit_web_view_reload_bypass_cache(self)
    end


    # uri_ -> 
    # returns:  -> void
    def load_uri(uri_)
      r = Lib.webkit_web_view_load_uri(self,uri_)
    end


    # content_ -> 
    # mime_type_ -> 
    # encoding_ -> 
    # base_uri_ -> 
    # returns:  -> void
    def load_string(content_,mime_type_,encoding_,base_uri_)
      r = Lib.webkit_web_view_load_string(self,content_,mime_type_,encoding_,base_uri_)
    end


    # content_ -> 
    # base_uri_ -> 
    # returns:  -> void
    def load_html_string(content_,base_uri_)
      r = Lib.webkit_web_view_load_html_string(self,content_,base_uri_)
    end


    # request_ -> 
    # returns:  -> void
    def load_request(request_)
      begin; request_ = RGI.rval2gobj(request_); rescue; end
      r = Lib.webkit_web_view_load_request(self,request_)
    end


    # text_ -> 
    # case_sensitive_ -> 
    # forward_ -> 
    # wrap_ -> 
    # returns:  -> bool
    def search_text(text_,case_sensitive_,forward_,wrap_)
      r = Lib.webkit_web_view_search_text(self,text_,case_sensitive_,forward_,wrap_)
    end


    # string_ -> 
    # case_sensitive_ -> 
    # limit_ -> 
    # returns:  -> int
    def mark_text_matches(string_,case_sensitive_,limit_)
      r = Lib.webkit_web_view_mark_text_matches(self,string_,case_sensitive_,limit_)
    end


    # highlight_ -> 
    # returns:  -> void
    def set_highlight_text_matches(highlight_)
      r = Lib.webkit_web_view_set_highlight_text_matches(self,highlight_)
    end


    # returns:  -> void
    def unmark_text_matches()
      r = Lib.webkit_web_view_unmark_text_matches(self)
    end


    # returns:  -> pointer
    def get_main_frame()
      r = Lib.webkit_web_view_get_main_frame(self)
      begin
       
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_focused_frame()
      r = Lib.webkit_web_view_get_focused_frame(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # script_ -> 
    # returns:  -> void
    def execute_script(script_)
      r = Lib.webkit_web_view_execute_script(self,script_)
    end


    # returns:  -> bool
    def can_cut_clipboard()
      r = Lib.webkit_web_view_can_cut_clipboard(self)
    end


    # returns:  -> bool
    def can_copy_clipboard()
      r = Lib.webkit_web_view_can_copy_clipboard(self)
    end


    # returns:  -> bool
    def can_paste_clipboard()
      r = Lib.webkit_web_view_can_paste_clipboard(self)
    end


    # returns:  -> void
    def cut_clipboard()
      r = Lib.webkit_web_view_cut_clipboard(self)
    end


    # returns:  -> void
    def copy_clipboard()
      r = Lib.webkit_web_view_copy_clipboard(self)
    end


    # returns:  -> void
    def paste_clipboard()
      r = Lib.webkit_web_view_paste_clipboard(self)
    end


    # returns:  -> void
    def delete_selection()
      r = Lib.webkit_web_view_delete_selection(self)
    end


    # returns:  -> bool
    def has_selection()
      r = Lib.webkit_web_view_has_selection(self)
    end


    # returns:  -> void
    def select_all()
      r = Lib.webkit_web_view_select_all(self)
    end


    # returns:  -> bool
    def get_editable()
      r = Lib.webkit_web_view_get_editable(self)
    end


    # flag_ -> 
    # returns:  -> void
    def set_editable(flag_)
      r = Lib.webkit_web_view_set_editable(self,flag_)
    end


    # returns:  -> pointer
    def get_copy_target_list()
      r = Lib.webkit_web_view_get_copy_target_list(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_paste_target_list()
      r = Lib.webkit_web_view_get_paste_target_list(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # settings_ -> 
    # returns:  -> void
    def set_settings(settings_)
      begin; settings_ = RGI.rval2gobj(settings_); rescue; end
      r = Lib.webkit_web_view_set_settings(self,settings_)
    end


    # returns:  -> pointer
    def get_settings()
      r = Lib.webkit_web_view_get_settings(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_inspector()
      r = Lib.webkit_web_view_get_inspector(self)
      p [:insp_ptr,r]
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_window_features()
      r = Lib.webkit_web_view_get_window_features(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # mime_type_ -> 
    # returns:  -> bool
    def can_show_mime_type(mime_type_)
      r = Lib.webkit_web_view_can_show_mime_type(self,mime_type_)
    end


    # returns:  -> bool
    def get_transparent()
      r = Lib.webkit_web_view_get_transparent(self)
    end


    # flag_ -> 
    # returns:  -> void
    def set_transparent(flag_)
      r = Lib.webkit_web_view_set_transparent(self,flag_)
    end


    # returns:  -> pointer
    def get_zoom_level()
      r = Lib.webkit_web_view_get_zoom_level(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # zoom_level_ -> 
    # returns:  -> void
    def set_zoom_level(zoom_level_)
      zoom_level_ = zoom_level_.to_f
      r = Lib.webkit_web_view_set_zoom_level(self,zoom_level_)
    end


    # returns:  -> void
    def zoom_in()
      r = Lib.webkit_web_view_zoom_in(self)
    end


    # returns:  -> void
    def zoom_out()
      r = Lib.webkit_web_view_zoom_out(self)
    end


    # returns:  -> bool
    def get_full_content_zoom()
      r = Lib.webkit_web_view_get_full_content_zoom(self)
    end


    # full_content_zoom_ -> 
    # returns:  -> void
    def set_full_content_zoom(full_content_zoom_)
      r = Lib.webkit_web_view_set_full_content_zoom(self,full_content_zoom_)
    end


    # returns:  -> pointer
    def webkit_get_default_session()
      r = Lib.webkit_get_default_session(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> string
    def get_encoding()
      r = Lib.webkit_web_view_get_encoding(self)
    end


    # encoding_ -> 
    # returns:  -> void
    def set_custom_encoding(encoding_)
      r = Lib.webkit_web_view_set_custom_encoding(self,encoding_)
    end


    # returns:  -> pointer
    def get_custom_encoding()
      r = Lib.webkit_web_view_get_custom_encoding(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # step_ -> 
    # count_ -> 
    # returns:  -> void
    def move_cursor(step_,count_)
      begin; step_ = RGI.rval2gobj(step_); rescue; end
      r = Lib.webkit_web_view_move_cursor(self,step_,count_)
    end


    # returns:  -> pointer
    def get_load_status()
      r = Lib.webkit_web_view_get_load_status(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_progress()
      r = Lib.webkit_web_view_get_progress(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> void
    def undo()
      r = Lib.webkit_web_view_undo(self)
    end


    # returns:  -> bool
    def can_undo()
      r = Lib.webkit_web_view_can_undo(self)
    end


    # returns:  -> void
    def redo()
      r = Lib.webkit_web_view_redo(self)
    end


    # returns:  -> bool
    def can_redo()
      r = Lib.webkit_web_view_can_redo(self)
    end


    # view_source_mode_ -> 
    # returns:  -> void
    def set_view_source_mode(view_source_mode_)
      r = Lib.webkit_web_view_set_view_source_mode(self,view_source_mode_)
    end


    # returns:  -> bool
    def get_view_source_mode()
      r = Lib.webkit_web_view_get_view_source_mode(self)
    end


    # event_ -> 
    # returns:  -> pointer
    def get_hit_test_result(event_)
      begin; event_ = RGI.rval2gobj(event_); rescue; end
      r = Lib.webkit_web_view_get_hit_test_result(self,event_)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> string
    def get_icon_uri()
      r = Lib.webkit_web_view_get_icon_uri(self)
    end


    # cache_model_ -> 
    # returns:  -> void
    def webkit_set_cache_model(cache_model_)
      begin; cache_model_ = RGI.rval2gobj(cache_model_); rescue; end
      r = Lib.webkit_set_cache_model(self,cache_model_)
    end


    # returns:  -> pointer
    def webkit_get_cache_model()
      r = Lib.webkit_get_cache_model(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_dom_document()
      r = Lib.webkit_web_view_get_dom_document(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def initialize(*o)
      if o[0].is_a? Hash
	    if ptr=o[0][:ptr]
	      @ptr = ptr
   	    else
	      fail('Invalid construct')
	    end
      else
	    @ptr = self.class.real_new(*o)
      end
      super @ptr
    end
    
    def to_ptr
      @ptr
    end
    
    def self.real_new()
      Lib.webkit_web_view_new()
    end



  end
end


#       webkit_hard_code_full.rb
             
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
require File.join(File.dirname(__FILE__),"webkit","WebKitDownload")
require File.join(File.dirname(__FILE__),"webkit","WebKitHitTestResult")
require File.join(File.dirname(__FILE__),"webkit","WebKitNetworkRequest")
require File.join(File.dirname(__FILE__),"webkit","WebKitNetworkResponse")
require File.join(File.dirname(__FILE__),"webkit","WebKitSoupAuthDialog")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebBackForwardList")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebDataSource")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebFrame")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebHistoryItem")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebInspector")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebNavigationAction")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebPolicyDecision")
require File.join(File.dirname(__FILE__),"webkit","WebKitGeolocationPolicyDecision")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebResource")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebSettings")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebWindowFeatures")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebView")
require File.join(File.dirname(__FILE__),"webkit","WebKitWebDatabase")
require File.join(File.dirname(__FILE__),"webkit","WebKitSecurityOrigin")

module WebKit
  module Lib
    module WebKitGFFI
      extend FFI::Library
      ffi_lib(JS::Config[:WebKit][:lib] || 'webkit-1.0')
    end
    extend WebKitGFFI
  end
end

class FFI::NotFoundError < LoadError
  def initialize *o
    haha!
  end
end

module WebKit::Lib::WebKitGFFI
  def self.attach_func(*o)
    attach_function *o
  rescue => e
    puts "Warning: Could not attach foriegn-function: #{o[0]}."
  end


  attach_func :webkit_download_get_type,[:pointer],:int
  attach_func :webkit_download_start,[:pointer],:void
  attach_func :webkit_download_cancel,[:pointer],:void
  attach_func :webkit_download_get_uri,[:pointer],:string
  attach_func :webkit_download_get_network_request,[:pointer],:pointer
  attach_func :webkit_download_get_network_response,[:pointer],:pointer
  attach_func :webkit_download_get_suggested_filename,[:pointer],:string
  attach_func :webkit_download_get_destination_uri,[:pointer],:string
  attach_func :webkit_download_set_destination_uri,[:pointer,:string],:void
  attach_func :webkit_download_get_progress,[:pointer],:pointer
  attach_func :webkit_download_get_elapsed_time,[:pointer],:pointer
  attach_func :webkit_download_get_total_size,[:pointer],:int
  attach_func :webkit_download_get_current_size,[:pointer],:int
  attach_func :webkit_download_get_status,[:pointer],:pointer
  attach_func :webkit_download_new,[:pointer],:pointer
  attach_func :webkit_hit_test_result_get_type,[:pointer],:int
  attach_func :webkit_network_request_get_type,[:pointer],:int
  attach_func :webkit_network_request_set_uri,[:pointer,:string],:void
  attach_func :webkit_network_request_get_uri,[:pointer],:string
  attach_func :webkit_network_request_get_message,[:pointer],:pointer
  attach_func :webkit_network_request_new,[:string],:pointer
  attach_func :webkit_network_response_get_type,[:pointer],:int
  attach_func :webkit_network_response_set_uri,[:pointer,:string],:void
  attach_func :webkit_network_response_get_uri,[:pointer],:string
  attach_func :webkit_network_response_get_message,[:pointer],:pointer
  attach_func :webkit_network_response_new,[:string],:pointer
  attach_func :webkit_soup_auth_dialog_get_type,[:pointer],:int
  attach_func :webkit_web_back_forward_list_get_type,[:pointer],:int
  attach_func :webkit_web_back_forward_list_go_forward,[:pointer],:void
  attach_func :webkit_web_back_forward_list_go_back,[:pointer],:void
  attach_func :webkit_web_back_forward_list_contains_item,[:pointer,:pointer],:bool
  attach_func :webkit_web_back_forward_list_go_to_item,[:pointer,:pointer],:void
  attach_func :webkit_web_back_forward_list_get_forward_list_with_limit,[:pointer,:int],:pointer
  attach_func :webkit_web_back_forward_list_get_back_list_with_limit,[:pointer,:int],:pointer
  attach_func :webkit_web_back_forward_list_get_back_item,[:pointer],:pointer
  attach_func :webkit_web_back_forward_list_get_current_item,[:pointer],:pointer
  attach_func :webkit_web_back_forward_list_get_forward_item,[:pointer],:pointer
  attach_func :webkit_web_back_forward_list_get_nth_item,[:pointer,:int],:pointer
  attach_func :webkit_web_back_forward_list_get_back_length,[:pointer],:int
  attach_func :webkit_web_back_forward_list_get_forward_length,[:pointer],:int
  attach_func :webkit_web_back_forward_list_get_limit,[:pointer],:int
  attach_func :webkit_web_back_forward_list_set_limit,[:pointer,:int],:void
  attach_func :webkit_web_back_forward_list_add_item,[:pointer,:pointer],:void
  attach_func :webkit_web_back_forward_list_clear,[:pointer],:void
  attach_func :webkit_web_back_forward_list_new_with_web_view,[:pointer],:pointer
  attach_func :webkit_web_data_source_get_type,[:pointer],:int
  attach_func :webkit_web_data_source_get_web_frame,[:pointer],:pointer
  attach_func :webkit_web_data_source_get_initial_request,[:pointer],:pointer
  attach_func :webkit_web_data_source_get_request,[:pointer],:pointer
  attach_func :webkit_web_data_source_get_encoding,[:pointer],:string
  attach_func :webkit_web_data_source_is_loading,[:pointer],:bool
  attach_func :webkit_web_data_source_get_data,[:pointer],:pointer
  attach_func :webkit_web_data_source_get_main_resource,[:pointer],:pointer
  attach_func :webkit_web_data_source_get_unreachable_uri,[:pointer],:string
  attach_func :webkit_web_data_source_get_subresources,[:pointer],:pointer
  attach_func :webkit_web_data_source_new,[],:pointer
  attach_func :webkit_web_data_source_new_with_request,[:pointer],:pointer
  attach_func :webkit_web_frame_get_type,[:pointer],:int
  attach_func :webkit_web_frame_get_web_view,[:pointer],:pointer
  attach_func :webkit_web_frame_get_name,[:pointer],:string
  attach_func :webkit_web_frame_get_title,[:pointer],:string
  attach_func :webkit_web_frame_get_uri,[:pointer],:string
  attach_func :webkit_web_frame_get_parent,[:pointer],:pointer
  attach_func :webkit_web_frame_load_uri,[:pointer,:string],:void
  attach_func :webkit_web_frame_load_string,[:pointer,:string,:string,:string,:string],:void
  attach_func :webkit_web_frame_load_alternate_string,[:pointer,:string,:string,:string],:void
  attach_func :webkit_web_frame_load_request,[:pointer,:pointer],:void
  attach_func :webkit_web_frame_stop_loading,[:pointer],:void
  attach_func :webkit_web_frame_reload,[:pointer],:void
  attach_func :webkit_web_frame_find_frame,[:pointer,:string],:pointer
  attach_func :webkit_web_frame_get_global_context,[:pointer],:pointer
  attach_func :webkit_web_frame_print_full,[:pointer,:int,:int,:pointer],:int
  attach_func :webkit_web_frame_print,[:pointer],:void
  attach_func :webkit_web_frame_get_load_status,[:pointer],:pointer
  attach_func :webkit_web_frame_get_horizontal_scrollbar_policy,[:pointer],:int
  attach_func :webkit_web_frame_get_vertical_scrollbar_policy,[:pointer],:int
  attach_func :webkit_web_frame_get_data_source,[:pointer],:pointer
  attach_func :webkit_web_frame_get_provisional_data_source,[:pointer],:pointer
  attach_func :webkit_web_frame_get_security_origin,[:pointer],:pointer
  attach_func :webkit_web_frame_get_network_response,[:pointer],:pointer
  attach_func :webkit_web_frame_new,[:pointer],:pointer
  attach_func :webkit_web_history_item_get_type,[:pointer],:int
  attach_func :webkit_web_history_item_get_title,[:pointer],:string
  attach_func :webkit_web_history_item_get_alternate_title,[:pointer],:string
  attach_func :webkit_web_history_item_set_alternate_title,[:pointer,:string],:void
  attach_func :webkit_web_history_item_get_uri,[:pointer],:string
  attach_func :webkit_web_history_item_get_original_uri,[:pointer],:string
  attach_func :webkit_web_history_item_get_last_visited_time,[:pointer],:pointer
  attach_func :webkit_web_history_item_copy,[:pointer],:pointer
  attach_func :webkit_web_history_item_new,[],:pointer
  attach_func :webkit_web_history_item_new_with_data,[:string,:string],:pointer
  attach_func :webkit_web_inspector_get_type,[:pointer],:int
  attach_func :webkit_web_inspector_get_web_view,[:pointer],:pointer
  attach_func :webkit_web_inspector_get_inspected_uri,[:pointer],:string
  attach_func :webkit_web_inspector_inspect_coordinates,[:pointer,:pointer,:pointer],:void
  attach_func :webkit_web_inspector_show,[:pointer],:void
  attach_func :webkit_web_inspector_close,[:pointer],:void
  attach_func :webkit_web_navigation_action_get_type,[:pointer],:int
  attach_func :webkit_web_navigation_action_get_reason,[:pointer],:pointer
  attach_func :webkit_web_navigation_action_set_reason,[:pointer,:pointer],:void
  attach_func :webkit_web_navigation_action_get_original_uri,[:pointer],:string
  attach_func :webkit_web_navigation_action_set_original_uri,[:pointer,:string],:void
  attach_func :webkit_web_navigation_action_get_button,[:pointer],:int
  attach_func :webkit_web_navigation_action_get_modifier_state,[:pointer],:int
  attach_func :webkit_web_navigation_action_get_target_frame,[:pointer],:string
  attach_func :webkit_web_policy_decision_get_type,[:pointer],:int
  attach_func :webkit_web_policy_decision_use,[:pointer],:void
  attach_func :webkit_web_policy_decision_ignore,[:pointer],:void
  attach_func :webkit_web_policy_decision_download,[:pointer],:void
  attach_func :webkit_geolocation_policy_decision_get_type,[:pointer],:int
  attach_func :webkit_geolocation_policy_allow,[:pointer],:void
  attach_func :webkit_geolocation_policy_deny,[:pointer],:void
  attach_func :webkit_web_resource_get_type,[:pointer],:int
  attach_func :webkit_web_resource_get_data,[:pointer],:pointer
  attach_func :webkit_web_resource_get_uri,[:pointer],:string
  attach_func :webkit_web_resource_get_mime_type,[:pointer],:string
  attach_func :webkit_web_resource_get_encoding,[:pointer],:string
  attach_func :webkit_web_resource_get_frame_name,[:pointer],:string
  attach_func :webkit_web_resource_new,[:string,:size_t,:string,:string,:string,:string],:pointer
  attach_func :webkit_web_settings_get_type,[:pointer],:int
  attach_func :webkit_web_settings_copy,[:pointer],:pointer
  attach_func :webkit_web_settings_get_user_agent,[:pointer],:string
  attach_func :webkit_web_settings_new,[],:pointer
  attach_func :webkit_web_window_features_get_type,[:pointer],:int
  attach_func :webkit_web_window_features_equal,[:pointer,:pointer,:pointer],:bool
  attach_func :webkit_web_window_features_new,[],:pointer
  attach_func :webkit_web_view_get_type,[:pointer],:int
  attach_func :webkit_web_view_get_title,[:pointer],:string
  attach_func :webkit_web_view_get_uri,[:pointer],:string
  attach_func :webkit_web_view_set_maintains_back_forward_list,[:pointer,:bool],:void
  attach_func :webkit_web_view_get_back_forward_list,[:pointer],:pointer
  attach_func :webkit_web_view_go_to_back_forward_item,[:pointer,:pointer],:bool
  attach_func :webkit_web_view_can_go_back,[:pointer],:bool
  attach_func :webkit_web_view_can_go_back_or_forward,[:pointer,:int],:bool
  attach_func :webkit_web_view_can_go_forward,[:pointer],:bool
  attach_func :webkit_web_view_go_back,[:pointer],:void
  attach_func :webkit_web_view_go_back_or_forward,[:pointer,:int],:void
  attach_func :webkit_web_view_go_forward,[:pointer],:void
  attach_func :webkit_web_view_stop_loading,[:pointer],:void
  attach_func :webkit_web_view_open,[:pointer,:string],:void
  attach_func :webkit_web_view_reload,[:pointer],:void
  attach_func :webkit_web_view_reload_bypass_cache,[:pointer],:void
  attach_func :webkit_web_view_load_uri,[:pointer,:string],:void
  attach_func :webkit_web_view_load_string,[:pointer,:string,:string,:string,:string],:void
  attach_func :webkit_web_view_load_html_string,[:pointer,:string,:string],:void
  attach_func :webkit_web_view_load_request,[:pointer,:pointer],:void
  attach_func :webkit_web_view_search_text,[:pointer,:string,:bool,:bool,:bool],:bool
  attach_func :webkit_web_view_mark_text_matches,[:pointer,:string,:bool,:int],:int
  attach_func :webkit_web_view_set_highlight_text_matches,[:pointer,:bool],:void
  attach_func :webkit_web_view_unmark_text_matches,[:pointer],:void
  attach_func :webkit_web_view_get_main_frame,[:pointer],:pointer
  attach_func :webkit_web_view_get_focused_frame,[:pointer],:pointer
  attach_func :webkit_web_view_execute_script,[:pointer,:string],:void
  attach_func :webkit_web_view_can_cut_clipboard,[:pointer],:bool
  attach_func :webkit_web_view_can_copy_clipboard,[:pointer],:bool
  attach_func :webkit_web_view_can_paste_clipboard,[:pointer],:bool
  attach_func :webkit_web_view_cut_clipboard,[:pointer],:void
  attach_func :webkit_web_view_copy_clipboard,[:pointer],:void
  attach_func :webkit_web_view_paste_clipboard,[:pointer],:void
  attach_func :webkit_web_view_delete_selection,[:pointer],:void
  attach_func :webkit_web_view_has_selection,[:pointer],:bool
  attach_func :webkit_web_view_select_all,[:pointer],:void
  attach_func :webkit_web_view_get_editable,[:pointer],:bool
  attach_func :webkit_web_view_set_editable,[:pointer,:bool],:void
  attach_func :webkit_web_view_get_copy_target_list,[:pointer],:pointer
  attach_func :webkit_web_view_get_paste_target_list,[:pointer],:pointer
  attach_func :webkit_web_view_set_settings,[:pointer,:pointer],:void
  attach_func :webkit_web_view_get_settings,[:pointer],:pointer
  attach_func :webkit_web_view_get_inspector,[:pointer],:pointer
  attach_func :webkit_web_view_get_window_features,[:pointer],:pointer
  attach_func :webkit_web_view_can_show_mime_type,[:pointer,:string],:bool
  attach_func :webkit_web_view_get_transparent,[:pointer],:bool
  attach_func :webkit_web_view_set_transparent,[:pointer,:bool],:void
  attach_func :webkit_web_view_get_zoom_level,[:pointer],:pointer
  attach_func :webkit_web_view_set_zoom_level,[:pointer,:pointer],:void
  attach_func :webkit_web_view_zoom_in,[:pointer],:void
  attach_func :webkit_web_view_zoom_out,[:pointer],:void
  attach_func :webkit_web_view_get_full_content_zoom,[:pointer],:bool
  attach_func :webkit_web_view_set_full_content_zoom,[:pointer,:bool],:void
  attach_func :webkit_get_default_session,[:pointer],:pointer
  attach_func :webkit_web_view_get_encoding,[:pointer],:string
  attach_func :webkit_web_view_set_custom_encoding,[:pointer,:string],:void
  attach_func :webkit_web_view_get_custom_encoding,[:pointer],:pointer
  attach_func :webkit_web_view_move_cursor,[:pointer,:pointer,:int],:void
  attach_func :webkit_web_view_get_load_status,[:pointer],:pointer
  attach_func :webkit_web_view_get_progress,[:pointer],:pointer
  attach_func :webkit_web_view_undo,[:pointer],:void
  attach_func :webkit_web_view_can_undo,[:pointer],:bool
  attach_func :webkit_web_view_redo,[:pointer],:void
  attach_func :webkit_web_view_can_redo,[:pointer],:bool
  attach_func :webkit_web_view_set_view_source_mode,[:pointer,:bool],:void
  attach_func :webkit_web_view_get_view_source_mode,[:pointer],:bool
  attach_func :webkit_web_view_get_hit_test_result,[:pointer,:pointer],:pointer
  attach_func :webkit_web_view_get_icon_uri,[:pointer],:string
  attach_func :webkit_set_cache_model,[:pointer,:pointer],:void
  attach_func :webkit_get_cache_model,[:pointer],:pointer
  attach_func :webkit_web_view_get_dom_document,[:pointer],:pointer
  attach_func :webkit_web_view_new,[],:pointer
  attach_func :webkit_web_database_get_type,[:pointer],:int
  attach_func :webkit_web_database_get_security_origin,[:pointer],:pointer
  attach_func :webkit_web_database_get_name,[:pointer],:string
  attach_func :webkit_web_database_get_display_name,[:pointer],:string
  attach_func :webkit_web_database_get_expected_size,[:pointer],:int
  attach_func :webkit_web_database_get_size,[:pointer],:int
  attach_func :webkit_web_database_get_filename,[:pointer],:string
  attach_func :webkit_web_database_remove,[:pointer],:void
  attach_func :webkit_remove_all_web_databases,[:pointer],:void
  attach_func :webkit_get_web_database_directory_path,[:pointer],:string
  attach_func :webkit_set_web_database_directory_path,[:pointer,:string],:void
  attach_func :webkit_get_default_web_database_quota,[:pointer],:int
  attach_func :webkit_set_default_web_database_quota,[:pointer,:int],:void
  attach_func :webkit_security_origin_get_type,[:pointer],:int
  attach_func :webkit_security_origin_get_protocol,[:pointer],:string
  attach_func :webkit_security_origin_get_host,[:pointer],:string
  attach_func :webkit_security_origin_get_port,[:pointer],:int
  attach_func :webkit_security_origin_get_web_database_usage,[:pointer],:int
  attach_func :webkit_security_origin_get_web_database_quota,[:pointer],:int
  attach_func :webkit_security_origin_set_web_database_quota,[:pointer,:int],:void
  attach_func :webkit_security_origin_get_all_web_databases,[:pointer],:pointer
end

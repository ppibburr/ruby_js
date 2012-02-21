class DownloadDialog
  attr_reader :view,:download
  def initialize view,dl
    @download = dl
    @view = view
  end
  def run(widget)
		dialog = Gtk::MessageDialog.new(widget,Gtk::Dialog::DESTROY_WITH_PARENT,Gtk::MessageDialog::QUESTION,Gtk::MessageDialog::BUTTONS_OK_CANCEL,"Save file: '%s' ?" % fn=download.get_suggested_filename)
		resp = dialog.run
		dialog.destroy

		if resp == Gtk::Dialog::RESPONSE_OK
			dialog = Gtk::FileChooserDialog.new("Save File As ...",widget,Gtk::FileChooser::ACTION_SAVE,nil,[ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ],[ Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT ])

			odg = nil

			dialog.filename = File.join(ENV['HOME'],'Downloads',fn)
			dialog.current_name = File.basename(fn)
			dialog.do_overwrite_confirmation = true

			dialog.signal_connect('response') do |w, r|
				odg = case r
					when Gtk::Dialog::RESPONSE_ACCEPT
						filename = dialog.filename
						puts "'ACCEPT' download filename is {{ #{filename} }}"

						download.set_destination_uri("file://"+filename)

						download.signal_connect('notify::progress') do |dl,progress|
							puts "Download: #{filename}, #{dl.get_property('progress')*100} complete"
							false
						end

						download.signal_connect('notify::status') do |dl,status|
							case dl.get_property('status').inspect
								when /error/
									puts "Download: #{filename}, error. ABORTED"
								when /finished/
									puts "Download: #{filename}, complete!"
								when /cancelled/
							else
							end
						end

						true
					when Gtk::Dialog::RESPONSE_CANCEL;
						"'CANCEL' (#{r}) button pressed"
						false
					else
						false
				end
				dialog.destroy
			end

			dialog.run

			return odg
		else
		  return false
		end
	end
	
end

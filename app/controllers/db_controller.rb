require 'dropbox_sdk'


# This is an example of a Rails 3 controller that authorizes an application
# and then uploads a file to the user's Dropbox.

# You must set these
APP_KEY = 'rsxbeyw58wsi779'
APP_SECRET = 'igshwr5e7lpse1j'
ACCESS_TYPE = :app_folder #The two valid values here are :app_folder and :dropbox
                          #The default is :app_folder, but your application might be
                          #set to have full :dropbox access.  Check your app at
                          #https://www.dropbox.com/developers/apps


# Examples routes for config/routes.rb  (Rails 3)
#match 'db/authorize', :controller => 'db', :action => 'authorize'
#match 'db/upload', :controller => 'db', :action => 'upload'

class DbController < ApplicationController
  #skip_before_filter  :check_authorization

    def index
      if session[:dropbox_session].blank?
        puts"@@@@@@@@@ form if"
        redirect_to "authorize"
      else
      puts"@@@@@@@@@ form else"
      dbsession = DropboxSession.deserialize(session[:dropbox_session])
      client = DropboxClient.new(dbsession, ACCESS_TYPE)
      metadata = client.metadata('/').inspect
      metadata = client.metadata(params[:path]).inspect unless params[:path].blank?
      @parse_metadata = eval(metadata)
      @breadcrumb = @parse_metadata['path'].split('/')
      puts"@@@@@@ count = #{@breadcrumb.length}"
      @contents = eval(@parse_metadata['contents'].inspect)
      index = 0
      @contents.each do |xx|
      puts "Metadata = #{@contents[index]['path']}"
      index +=1
      end
      end
    end

    def authorize
        if not params[:oauth_token] then
            dbsession = DropboxSession.new(APP_KEY, APP_SECRET)

            session[:dropbox_session] = dbsession.serialize #serialize and save this DropboxSession

            #pass to get_authorize_url a callback url that will return the user here
            redirect_to dbsession.get_authorize_url url_for(:action => 'authorize')
        else
            # the user has returned from Dropbox
            dbsession = DropboxSession.deserialize(session[:dropbox_session])
            dbsession.get_access_token  #we've been authorized, so now request an access_token
            session[:dropbox_session] = dbsession.serialize

            redirect_to :action => 'index'
        end
    end

    def upload
        # Check if user has no dropbox session...re-direct them to authorize
        return redirect_to(:action => 'authorize') unless session[:dropbox_session]

        dbsession = DropboxSession.deserialize(session[:dropbox_session])
        client = DropboxClient.new(dbsession, ACCESS_TYPE) #raise an exception if session not authorized

        if request.method != "POST"
            # show a file upload page
            render "upload"
            #:inline =>"#{info['email']} <br/><%= form_tag({:action => :upload}, :multipart => true) do %><%= file_field_tag 'file' %><%= submit_tag %><% end %>"
            return
        else
          if !params[:file].blank?
            # upload the posted file to dropbox keeping the same name
            file_name = "#{URI.decode(params[:path]).to_s}/#{params[:file].original_filename}"
            @resp = client.put_file(file_name, params[:file].read)
            redirect_to "/db/index?path=#{params[:path]}"
          else
            flash[:error] = "Please enter file name."
          end

        end
    end

    def upload_file
        return redirect_to(:action => 'authorize') unless session[:dropbox_session]
        dbsession = DropboxSession.deserialize(session[:dropbox_session])
        client = DropboxClient.new(dbsession, ACCESS_TYPE)
        if !params[:file].blank?
          file_name = "#{params[:path].to_s}/#{params[:file].original_filename}"
		  @resp = client.put_file(file_name, params[:file].read)
		end
    end

    def download
      return redirect_to(:action => 'authorize') unless session[:dropbox_session]
      dbsession = DropboxSession.deserialize(session[:dropbox_session])
      client = DropboxClient.new(dbsession, ACCESS_TYPE)

      out, metadata = client.get_file_and_metadata(params[:path])
      file = params[:path].split('/')
      tmp_file_path = Rails.root.join("tmp",file.last)
      File.open(tmp_file_path, 'w') {|f| f.puts out }
      send_file(tmp_file_path)
      File.delete(tmp_file_path)
	  return

      redirect_to :back
    end

    def delete_file
      return redirect_to(:action => 'authorize') unless session[:dropbox_session]
      dbsession = DropboxSession.deserialize(session[:dropbox_session])
      client = DropboxClient.new(dbsession, ACCESS_TYPE)
      client.file_delete(params[:path])
      redirect_to :back
    end

    def create_folder
      return redirect_to(:action => 'authorize') unless session[:dropbox_session]
      dbsession = DropboxSession.deserialize(session[:dropbox_session])
      client = DropboxClient.new(dbsession, ACCESS_TYPE)
      if request.method == 'POST'
      if params[:folder].blank?
        flash.now[:error] = "Please enter folder name."
      else
        folder_name = "#{URI.decode(params[:path]).to_s}/#{params[:folder]}"
        puts"@@@@@@@ #{folder_name}"
        @response = client.file_create_folder("#{folder_name}")
        puts"@@@ response = #{response}"
        redirect_to "/db/index?path=#{params[:path]}"
      end
      end
    end

end

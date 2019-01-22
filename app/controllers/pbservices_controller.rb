class PbservicesController < ApplicationController
 skip_before_filter :authorize_action

	def index
		@mail_request=0
	end

	def show
	 
    end

    def mail_request
      @mail_request  = 1
      email= Email.call_me(@current_user,@company).deliver
      if email
      	@mail_request=1
      end
	  respond_to do |format|
	  	format.js
	     format.html {render :action=> "index",:req_done => @mail_request}
	 end

    end
end




	


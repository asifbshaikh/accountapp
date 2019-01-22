class EmailTemplateController < ApplicationController
  def emailtemplate
    Email.create_user_confirmation.deliver
  end

end

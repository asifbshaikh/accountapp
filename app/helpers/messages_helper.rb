module MessagesHelper

  def message_from message
    if message.created_by == @current_user.id
      "you"
    else
      message.from.capitalize
    end  

  end  
end

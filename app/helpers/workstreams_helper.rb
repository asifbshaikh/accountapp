module WorkstreamsHelper
  
  def display_workstream_username(action_user)
    (@current_user.id == action_user.id) ? "You" : action_user.full_name
  end

  def workstream_span(action_code)
    if action_code == "created"
      badge = 'badge bg-success'
      icon = 'icon-plus'
    elsif action_code == "deleted"
      badge = 'badge bg-danger'
      icon = 'icon-trash'
    else
      badge = 'badge bg-info'
      icon = 'icon-edit'
    end

    raw("<span class='#{badge}'><i class='#{icon}'></i></span>")
  end

  def workstream_action_code(action_code)
    if action_code == "created"
      action_code = "added"
    end
    action_code
  end

  def workstream_action(sentence)
    if sentence.match(/created/)
      sentence["created"]=""
    elsif sentence.match(/updated/)
      sentence["updated"] =""
    elsif sentence.match(/deleted/)
      sentence["deleted"] =""
    end
    sentence
  end

end

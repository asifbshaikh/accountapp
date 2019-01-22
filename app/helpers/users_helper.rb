module UsersHelper

  def owner
   @company.plan.roles.find_by_name("Owner").id
  end

  def accountant
   @company.plan.roles.find_by_name("Accountant").id
  end

  def staff
   @company.plan.roles.find_by_name("Staff").id
  end

  def sales
   @company.plan.roles.find_by_name("Sales").id
  end

  def auditor
   @company.plan.roles.find_by_name("Auditor").id
  end

  def employee
    @company.plan.roles.find_by_name("Employee").id
  end

  def hr
    @company.plan.roles.find_by_name("HR").id
  end

  def inventory_manager
    @company.plan.roles.find_by_name("Inventory Manager").id
  end

  def branch_name(user)
    "Branch : #{user.branch_name}" unless user.branch_name.blank?
  end

  def user_avatar(user)
    avatar = user.avatar_file_name.blank? ? 'avatar_green.png' : user.avatar.url(:thumb)
    image_tag avatar, :alt=>"Avatar", :class=>'img-rounded'
  end

  def edit_link(user)
    if @current_user.owner? || user.id == @current_user.id
      link_to 'Edit', edit_user_path(user)
    else
       "Edit"
    end
  end

  def birth_date(user)
    user.birth_date.strftime("%d %b %y") unless user.birth_date.blank?
  end

  def joining_date(user)
    user.date_of_joining.strftime("%d %b %y") unless user.date_of_joining.blank?
  end

end

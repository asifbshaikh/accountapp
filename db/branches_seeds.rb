     free_plan = Plan.find_by_name('Free')
     basic_plan = Plan.find_by_name('Basic')
     premium_plan = Plan.find_by_name('Premium')
     enterprise_plan = Plan.find_by_name('Enterprise')
     essential_plan = Plan.find_by_name('Essential')

     free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)
     basic_owner = Role.find_by_name_and_plan_id('Owner', basic_plan)
     premium_owner = Role.find_by_name_and_plan_id('Owner', premium_plan)
     enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
     essential_owner = Role.find_by_name_and_plan_id('Owner', essential_plan)

      # invoice_settings_create = Right.create!(:resource => 'invoice_settings', :operation => 'CREATE')
      # invoice_settings_read = Right.create!(:resource => 'invoice_settings', :operation => 'READ') 
      # invoice_settings_delete = Right.create!(:resource => 'invoice_settings', :operation => 'DELETE')
      # invoice_settings_update = Right.create!(:resource => 'invoice_settings', :operation => 'UPDATE')


      branches_create = Right.create!(:resource => 'branches', :operation => 'CREATE')
      branches_read = Right.create!(:resource => 'branches', :operation => 'READ') 
      branches_delete = Right.create!(:resource => 'branches', :operation => 'DELETE')
      branches_update = Right.create!(:resource => 'branches', :operation => 'UPDATE')

#      #free_owner.rights << custom_fields_create
#      free_owner.rights << invoice_settings_read
#      free_owner.rights << invoice_settings_update
#      #free_owner.rights << invoice_settings_delete
   
#    # #essential_owner  
#       #essential_owner.rights << invoice_settings_create
#       essential_owner.rights << invoice_settings_read
#       essential_owner.rights << invoice_settings_update
#       #essential_owner.rights << invoice_settings_delete


# #   #   #basic_owner   
#       #basic_owner.rights << invoice_settings_create
#       basic_owner.rights << invoice_settings_read
#       basic_owner.rights << invoice_settings_update
#       #basic_owner.rights << invoice_settings_delete


#    #     #premium_owner    
#      #premium_owner.rights << invoice_settings_create
#      premium_owner.rights << invoice_settings_read
#      premium_owner.rights << invoice_settings_update
#      #premium_owner.rights << invoice_settings_delete

#    #   #enterprise_owner 
#      #enterprise_owner.rights << invoice_settings_create
#      enterprise_owner.rights << invoice_settings_read
#      enterprise_owner.rights << invoice_settings_update
#      #enterprise_owner.rights << invoice_settings_delete

   #   #enterprise_owner 
     enterprise_owner.rights << branches_create
     enterprise_owner.rights << branches_read
     enterprise_owner.rights << branches_update
     enterprise_owner.rights << branches_delete




 #  #creating default leave cards
 #  @companies = Company.all
 #  @companies.each do |company|
 #  ActiveRecord::Base.transaction do
 #  #---------country_company_entry for old companies-------
 #   @country_company = CountryCompany.find_by_company_id(company.id)
 #   if @country_company.blank?
 #     @country_company = CountryCompany.new(:company_id => company.id)
 #     @country_company.save!
 #   end  
 #  #------------------------------- 
 # #------leave card code start 
 #   if company.plan.payroll_enabled?  
 #   #leave type creation for payroll enabled companies
    
    
 #     @leave_types = company.leave_types
 #      @users = company.users
 #      # if @leave_types.blank?
 #      #   @users.each do |user|
 #      #     leave_type = LeaveType.create(:company_id => company.id, :created_by => user.id, :leave_type=> "Sick Leave", :allowed_leaves => 10)
 #      #     leave_type = LeaveType.create(:company_id => company.id, :created_by => user.id, :leave_type=> "Casual Leave", :allowed_leaves => 10)
 #      #     leave_type = LeaveType.create(:company_id => company.id, :created_by => user.id, :leave_type=> "Leave without pay", :allowed_leaves => 10) 
 #      #   end
 #      # end
 #      # @leave_types = company.leave_types
 #     puts"@@@ leave type count is #{@leave_types.count}"
    
 #     puts"@@@ user count is #{@users.count}"
    
 #     result = false
 #      @leave_types.each do |leave_type|
 #         @users.each do |user| 
 #           @leave_card = LeaveCard.find_by_user_id_and_card_year_and_leave_type_id(user.id, Time.zone.now.year, leave_type.id)
 #           puts"@@@ leave card is present already #{@leave_card==true}"
 #           if @leave_card.blank? 
 #             @leave_card = LeaveCard.new(:company_id => company.id,
 #                                    :user_id => user.id,
 #                                    :leave_type_id => leave_type.id,
 #                                    :card_year => Time.zone.now.year,
 #                                    :total_leave_cnt => leave_type.allowed_leaves,
 #                                    :utilized_leave_cnt => 0)
 #             @leave_card.save!
 #             puts"@@@ inside user loop count "
 #           end
 #         puts"@@@ inside leave type loop count "
 #       end  
 #    end
 #    #---------------leave card loop ends-------
 #       result = true
 #     end
 #     result
 #    end
 #  end

ActiveRecord::Base.transaction do
	professional_plan = Plan.find_by_name('Professional')
	enterprise_plan = Plan.find_by_name('Enterprise')
	trial_plan = Plan.find_by_name('Trial')
	smb_plan = Plan.find_by_name('SMB')
	
	professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
	professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
	professional_auditor = Role.find_by_name_and_plan_id('Auditor', professional_plan)

	enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
	enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
	enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)

	trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
	trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
	trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
	
	smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
	smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
	smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)

	payroll_execution_job_create = Right.create!(:resource=>'payroll_execution_jobs', :operation=>'CREATE')
	payroll_execution_job_read = Right.create!(:resource=>'payroll_execution_jobs', :operation=>'READ')

	# professional_owner
	professional_owner.rights<<payroll_execution_job_create
	professional_owner.rights<<payroll_execution_job_read

	# professional_accountant
	professional_accountant.rights<<payroll_execution_job_create
	professional_accountant.rights<<payroll_execution_job_read

	# professional_auditor
	professional_auditor.rights<<payroll_execution_job_read

	# enterprise_owner
	enterprise_owner.rights<<payroll_execution_job_create
	enterprise_owner.rights<<payroll_execution_job_read

	# enterprise_accountant
	enterprise_accountant.rights<<payroll_execution_job_create
	enterprise_accountant.rights<<payroll_execution_job_read

	# enterprise_auditor
	enterprise_auditor.rights<<payroll_execution_job_read

	# trial_owner
	trial_owner.rights<<payroll_execution_job_create
	trial_owner.rights<<payroll_execution_job_read

	# trial_accountant
	trial_accountant.rights<<payroll_execution_job_create
	trial_accountant.rights<<payroll_execution_job_read

	# trial_auditor
	trial_auditor.rights<<payroll_execution_job_read

	# smb_owner
	smb_owner.rights<<payroll_execution_job_create
	smb_owner.rights<<payroll_execution_job_read

	# smb_accountant
	smb_accountant.rights<<payroll_execution_job_create
	smb_accountant.rights<<payroll_execution_job_read

	# smb_auditor
	smb_auditor.rights<<payroll_execution_job_read
end
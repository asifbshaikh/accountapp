namespace :template do
	task :create_default_margins => :environment do
  	ActiveRecord::Base.transaction do
  	@companies = Company.where("id > 7785")
  	@templates = Template.all
  	 @companies.each do |company|

  	 	@templates.each do |template|

  	 		template_margin = TemplateMargin.new
  	 		template_margin.template_id = template.id
  	 		template_margin.hide_logo = 0
  	 		template_margin.hide_address = 0
  	 		template_margin.top_margin = 10
  	 		template_margin.left_margin = 10
  	 		template_margin.right_margin =20
  	 		template_margin.company_id = company.id
  	 		template_margin.save!
  	 	end

  	 	puts "template Details Created for #{company.name}"
  	 end
	end
end
end


pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
        pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
	    pdf.text "#{@company.address.get_address unless @company.address.blank?}",:align => :center, :size => 10
		pdf.move_down 5
        pdf.text "<u>Trial Balance</u>", :align => :center, :inline_format => true, :size => 12
		if !params[:branch_id].blank?
    pdf.text "Branch: #{Branch.find(params[:branch_id]).name}", :align => :center, :size => 6
    end
    pdf.text "#{ (params[:start_date].blank?) ? @financial_year.start_date : params[:start_date] } To #{ (params[:end_date].blank?)? ((Time.zone.now.to_date > @financial_year.end_date)? @financial_year.end_date : Time.zone.now.to_date) : params[:end_date] }", :align => :center, :size => 6
	end
	pdf.move_down 10

	data = [[ 'P a r t i c u l a r s', "Opening Balance (#{@company.currency_code})", "Debit (#{@company.currency_code})", "Credit (#{@company.currency_code})", "Closing Balance (#{@company.currency_code})"]]
	total_debit = 0
			sufix=''
	      if !@opening_inventory_valuation.blank? && @opening_inventory_valuation < 0
			  	sufix = " Cr"
	      elsif !@opening_inventory_valuation.blank? && @opening_inventory_valuation > 0
			  	sufix = " Dr"
        end
       total_credit = 0
       total_closing_balance = 0
		   total_opening_balance = 0
       branch = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
       start_date = params[:start_date].blank? ? @financial_year.start_date : params[:start_date].to_date
       end_date = params[:end_date].blank? ? @financial_year.end_date : params[:end_date].to_date
    data +=[[{:content => "Stock Valuation", :font_style => :bold},{:content => "#{number_with_precision(@opening_inventory_valuation, :precision => 2)} #{sufix}", :align=>:right}, "", "", {:content => "#{number_with_precision(@closing_inventory_valuation, :precision => 2)} #{sufix}", :align=>:right}]]

    for acc_head in @account_heads
		  data +=[[{:content => "#{acc_head.name}", :font_style => :bold},'','','','']]

      children_accounts = Array.new
      AccountHead.where(:id => acc_head).each{|acc| children_accounts << acc}
      children_accounts.each do |child_account_head|
        AccountHead.where(:parent_id => child_account_head).each{|acc| children_accounts << acc} unless child_account_head.get_children.blank?
      end

      children_accounts.each do |child_account|
        if child_account.parent_id.present?
		      data +=[[{:content => "#{child_account.name}", :font_style => :bold},'','','','']]
        end
        for acc in child_account.current_period_accounts(end_date)
          op_sufix = ''
          cl_sufix = ''
          opening_balance = 0
          opening_balance = acc.get_opening_balance(@current_user, @company.id, @financial_year, params[:start_date], branch)
          total_opening_balance += opening_balance

          if !opening_balance.blank? && opening_balance < 0
            op_sufix = " Cr"
            opening_balance = opening_balance.abs
          elsif !opening_balance.blank? && opening_balance > 0
            op_sufix = " Dr"
          end

          credit = Ledger.by_branch(branch).ledgers_in_current_year(@company, acc.id, start_date, end_date).sum(:credit)
          debit = Ledger.by_branch(branch).ledgers_in_current_year(@company, acc.id, start_date, end_date).sum(:debit)
          total_credit += credit
          total_debit += debit
          closing_balance = 0
          closing_balance = acc.get_closing_balance(@current_user, @company.id, @financial_year, end_date, branch)
          total_closing_balance += closing_balance
          if !closing_balance.blank? && closing_balance < 0
            cl_sufix = " Cr"
            closing_balance = closing_balance.abs
          elsif !closing_balance.blank? && closing_balance > 0
            cl_sufix = " Dr"
          end

          #This condition was changed to show accounts with no transaction in current FY but having opening & closing balance
          #Also this condtion now matches condition in index.html
          #Author: Ashish Wadekar
          #Date: 14 March 2017
          if closing_balance != 0 || debit != 0 || credit != 0 || opening_balance != 0
            amount = closing_balance
            data +=[["#{acc.name}",{:content => "#{number_with_precision(opening_balance, :precision => 2)} #{op_sufix}", :align=>:right},{:content => "#{number_with_precision(debit, :precision => 2)}", :align=>:right},{:content =>"#{number_with_precision(credit, :precision => 2)}", :align=>:right}, {:content => "#{number_with_precision(closing_balance, :precision => 2)} #{cl_sufix}", :align=>:right}]]
          end
        end
      end
    end
	data +=[["Profit/Loss  Account",{:content=>"#{number_with_precision(@opening_balance_difference, :precision => 2)}"},"","",{:content => "#{number_with_precision(@opening_balance_difference, :precision => 2)}"}]]



  data += [[{:content =>'Grand Total', :font_style => :bold},{:content => "#{number_with_precision((total_opening_balance + @opening_balance_difference + @opening_inventory_valuation), :precision => 2)}",:font_style => :bold, :align=>:right},{:content => "#{number_with_precision(total_debit, :precision => 2)}",:font_style => :bold, :align=>:right},{:content =>"#{number_with_precision(total_credit, :precision => 2)}", :font_style => :bold, :align=>:right},{:content => "#{number_with_precision((total_closing_balance + @opening_balance_difference + @opening_inventory_valuation), :precision => 2)}",:font_style => :bold, :align=>:right}]]

	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 8})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
	end

	pdf.page_count.times do |i|
		pdf.go_to_page(i+1)
		pdf.fill_color "ADADAD"
		if @footer.nil? || @footer.strip == ''
        pdf.draw_text "#{@company.watermark unless @company.watermark.blank?}", :at=>[0,-10], :size => 7
		else
			pdf.draw_text @footer.strip, :at => [0,-10], :size => 7
		end
		pdf.fill_color "000000"
		pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
	end

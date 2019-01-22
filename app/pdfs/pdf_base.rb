module PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper
	module ClassMethods
	end

	module InstanceMethods
		PAGE_LAYOUT={:page_layout=>:portrait, :paper_size=>"A4", :top_margin=>10, :left_margin=>10, :right_margin=>20}
		HORIZONTAL_PAGE_LAYOUT={:page_layout=>:landscape, :paper_size=>"A4", :top_margin=>10, :left_margin=>10, :right_margin=>10}

		def company_name_and_address
			table([
		     [ "<b>#{@company.name}</b>"],
		     [ "#{@company.address.get_address unless @company.address.blank?}"],
		     ["Phone: #{@company.phone unless @company.phone.blank?}"],
		     ["GSTIN: #{@company.GSTIN unless @company.GSTIN.blank?}"],
		    ], :width => bounds.width, :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 9})do
		  end
		end

		def company_name_and_address_in_center
			table([
		     [ "<b>#{@company.name}</b>"],
		     [ "#{@company.address.get_address unless @company.address.blank?}"],
		     ["Phone: #{@company.phone unless @company.phone.blank?}"],
		    ], :width => bounds.width, :cell_style =>{:border_width => 0,:align => :center, :inline_format => true, :size => 9})do
		  end
		end

		def company_logo
			if Rails.env.production?
			  image(open("#{@company.logo.url}"), :fit=>Prawn::Document::PageGeometry::SIZES["A8"]) unless @company.logo_file_name.blank?
			  else
		  	image( "#{Rails.root}/app/assets/images/logo.png", :fit=>Prawn::Document::PageGeometry::SIZES["A8"])
			 end
		end

		def retail_company_logo
			if Rails.env.production?
			  image(open("#{@company.logo.url}"), :fit=>Prawn::Document::PageGeometry::SIZES["A10"]) unless @company.logo_file_name.blank?
			else
				image( "#{Rails.root}/app/assets/images/logo.png", :fit=>Prawn::Document::PageGeometry::SIZES["A10"])
			end
		end


		def customer_details
			party_details([[{:content =>"Customer:", :font_style => :bold, :align => :left}]])
		end

		def vendor_details
			party_details([[{:content =>"Vendor:", :font_style => :bold, :align => :left}]])
		end

		def vendor_shipping_details
			po_shipping_details([[{:content =>"Shipping Address:", :font_style => :bold, :align => :left}]])
		end

		def party_details(header)
			data=header
			data<<["<b>#{@party.name}</b>"]
			unless @party.billing_address.blank?
			  data<<["#{@party.billing_address.get_address}"]
			end
			unless @party.email.blank?
			  data<<["Email : #{@party.email}"]
			end
			unless @party.contact_number.blank?
			  data<<["Contact : #{@party.primary_phone_number}"]
			end
			unless @party.pan.blank?
			  data<<["PAN : #{@party.pan}"]
			end
			unless @party.tan.blank?
			  data<<["TAN : #{@party.tan}"]
			end
			unless @party.vat_tin.blank?
			  data<<["VAT TIN : #{@party.vat_tin}"]
			end
			unless @party.gstn_id.blank?
			  data<<["GSTIN : #{@party.gstn_id}"]
			end

		  table(data, :width=>bounds.width,:cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
				row(0).borders = [:left, :right, :bottom, :top]
				row(0).background_color = 'F2F7FF'
				row(1..(data.size - 2)).borders = [:left, :right]
				row(data.size - 1).borders = [:left, :right, :bottom]
	 			row(0..(data.size - 1)).border_width = 0.2
	    end
		end

		def party_shipping_details(header)
			data=header
			data<<["<b>#{@party.name}</b>"]
			unless @party.shipping_address.blank?
			  data<<["#{@party.shipping_address.get_address}"]
			end
			unless @party.email.blank?
			  data<<["Email : #{@party.email}"]
			end
			unless @party.contact_number.blank?
			  data<<["Contact : #{@party.primary_phone_number}"]
			end
			unless @party.pan.blank?
			  data<<["PAN : #{@party.pan}"]
			end
			unless @party.tan.blank?
			  data<<["TAN : #{@party.tan}"]
			end
			unless @party.vat_tin.blank?
			  data<<["VAT TIN : #{@party.vat_tin}"]
			end

		  table(data, :width=>bounds.width,:cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
				row(0).borders = [:left, :right, :bottom, :top]
				row(0).background_color = 'F2F7FF'
				row(1..(data.size - 2)).borders = [:left, :right]
				row(data.size - 1).borders = [:left, :right, :bottom]
	 			row(0..(data.size - 1)).border_width = 0.2
	    end
		end

		#The PO shipping details is the address of the company generating the PO.
		def po_shipping_details(header)
			data=header
			data<<["<b>#{@company.name}</b>"]
			unless @company.address.blank?
			  data<<["#{@company.address.get_address}"]
			end
			unless @company.email.blank?
			  data<<["Email : #{@company.email}"]
			end
			unless @company.phone.blank?
			  data<<["Contact : #{@company.phone}"]
			end

		  table(data, :width=>bounds.width,:cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
				row(0).borders = [:left, :right, :bottom, :top]
				row(0).background_color = 'F2F7FF'
				row(1..(data.size - 2)).borders = [:left, :right]
				row(data.size - 1).borders = [:left, :right, :bottom]
	 			row(0..(data.size - 1)).border_width = 0.2
	    end


		end


		def signatory
			draw_text "-------------------", :at =>[bounds.width-70, 40]
			draw_text "Authorised Signatory",:size => 8,:at=>[bounds.width-70, 32]
		end

		def page_footer
			page_count.times do |i|
			  go_to_page(i+1)
			  fill_color "ADADAD"
			  if @footer.nil? || @footer.strip == ''
			   draw_text "#{@company.watermark unless @company.watermark.blank?}", :at=>[0,-30], :size => 7
			  else
			    draw_text @footer.strip, :at => [0,-30], :size => 7
			  end
			  fill_color "000000"
			  draw_text "Page : #{i+1} / #{page_count}", :at=>[bounds.width - 50,-30], :size => 8
			end
		end
	end

	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end

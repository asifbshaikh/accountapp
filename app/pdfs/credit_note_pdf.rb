class CreditNotePdf < Prawn::Document
	include PdfBase
	include ApplicationHelper
	def initialize(view_context, credit_note)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @credit_note=credit_note
	  @company=@credit_note.company
	  @pos_arr=[]
	  @header_pos=[]
	  send "generate_pdf"
	end

	def generate_pdf
		y_pos=cursor
		bounding_box([0, cursor], :width => (bounds.width/2) - 5) do 
		  company_logo
		  @header_pos<<y
		end

		bounding_box([(bounds.width/2), y_pos], :width => (bounds.width/2)) do
			company_name_and_address
			@header_pos<<y
		end
		
		bounding_box([0, (@header_pos.min.to_i-30)], :width=>bounds.width) do
			text "<b>CREDIT NOTE</b>", :align => :center, :inline_format => true, :size => 14
			stroke_horizontal_rule
		end
		self.y-=10
		text "<b>Voucher Number: </b> #{@credit_note.credit_note_number}", :align => :left, :inline_format => true, :size => 8
		self.y-=10
		text "<b>Credit Note Date: </b> #{@credit_note.transaction_date}", :align => :left, :inline_format => true, :size => 8
		self.y-=10
		text "<b>Credit For: </b> #{@credit_note.to_account_name}", :align => :left, :inline_format => true, :size => 8 
		unless @credit_note.read_only?
			self.y-=10
			text "<b>Credit Account Of: </b> #{@credit_note.from_account_name}", :align => :left, :inline_format => true, :size => 8 
		end
		self.y-=10
		text "<b>Amount: </b> #{@credit_note.currency} #{format_amount @credit_note.amount}", :align => :left, :inline_format => true, :size => 8

        self.y-=10
		text "<b>Description: </b> #{@credit_note.description} #{number_with_precision @credit_note.description, precision: 2}", :align => :left, :inline_format => true, :size => 8

		signatory
		page_footer
	end
end
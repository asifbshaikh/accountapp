pagecount = pdf.page_count
Prawn::Document.generate("footer.pdf", :skip_page_creation => true)
pdf.page_count.times do |i|
	pdf.go_to_page(i+1)
	pdf.fill_color "ADADAD"
	pdf.draw_text "Generated from www.profitnext.com", :at=>[0,-10], :size => 10
	pdf.fill_color "000000"
	pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[600,-10]
end

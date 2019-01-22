class StockSummaryService

  def initialize(company, user, categories=nil)
    @company = company
    @user = user
    @categories = categories
  end

  def stock_summary(start_date, end_date, branch_id)
    @start_date = start_date
    @end_date = end_date
    @branch_id= branch_id
    #@products = @company.products.where(:inventory=> true)
    @products = products
    @stocks_data = Array.new
    @products.each do |product|
      @stocks_data << StockProduct.new(product, @start_date, @end_date, @branch_id)
    end
    @stocks_data
  end

  private
    def products  
      if @categories.present?
        #logger.debug "==========Inside category=========="
        @company.products.tagged_with(@categories)
      else
        @company.products#.where(:inventory=> true)
      end
    end    

end

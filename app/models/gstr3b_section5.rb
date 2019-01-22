class Gstr3bSection5
  
  def initialize(purchases, expenses)
    @purchases = purchases
    @expenses = expenses
    process
  end

  def exempt_inter_tax_amt
    @exempt_inter_tax_amt ||= calc_exempt_inter_tax_amt
  end

  def exempt_intra_tax_amt
    @exempt_intra_tax_amt ||= calc_exempt_intra_tax_amt
  end

  def non_gst_intra_tax_amt
    @non_gst_intra_tax_amt ||= calc_non_gst_intra_tax_amt
  end

  def non_gst_inter_tax_amt
    @non_gst_tax_inter_amt ||= calc_non_gst_inter_tax_amt
  end

  private 

    def process
      @exempt_inter_expenses = Array.new
      @exempt_intra_expenses = Array.new
      @non_gst_intra_expenses = Array.new
      #separate exempt expenses and non tax expenses
      @expenses.each do |expense|
        if expense.tax_line_items.present?
          expense.tax_line_items.each do |tax_item|
            act_name = tax_item.account.name 
            if act_name.include? "IGST @Nil"
              @exempt_inter_expenses << expense
              break
            elsif act_name.include?("CGST @Nil") || act_name.include?("SGST @Nil") 
              @exempt_intra_expenses << expense
            end
          end
        else
          @non_gst_intra_expenses <<  expense
        end  
      end

      #classifying the purchase as intra state or inter state
      @exempt_inter_purchases = Array.new
      @exempt_intra_purchases = Array.new
      @non_gst_intra_purchases = Array.new
      @purchases.each do |purchase|
        if purchase.tax_line_items.present?
          purchase.tax_line_items.each do |tax_item|
            act_name = tax_item.account.name 
            if act_name.include? "IGST @Nil"
              @exempt_inter_purchases << purchase
              break
            elsif act_name.include?("CGST @Nil") || act_name.include?("SGST @Nil")
              @exempt_intra_purchases << purchase
              break
            end
          end
        else
          @non_gst_intra_purchases << purchase
        end  
      end
    end

    def calc_exempt_inter_tax_amt
      #sum of exempt inter expenses and purchases
      exempt_inter_tax_amt = 0
      @exempt_inter_expenses.each do |expense|
        exempt_inter_tax_amt += expense.sub_total
      end

      @exempt_inter_purchases.each do |purchase|
        exempt_inter_tax_amt += purchase.sub_total
      end

      exempt_inter_tax_amt
    end

    def calc_exempt_inter_tax_amt
      calc_totals(@exempt_inter_expenses, @exempt_inter_purchases)
    end

    def calc_exempt_intra_tax_amt
      calc_totals(@exempt_intra_expenses, @exempt_intra_purchases)
    end

    # def calc_non_gst_intra_tax_amt
    #   calc_totals(@non_gst_expenses, @exempt_intra_purchases)      
    # end

    def calc_non_gst_intra_tax_amt
      calc_totals(@non_gst_intra_expenses, @non_gst_intra_purchases)
    end

    #[NOTE] No idea how to calculate inter state for non gst purchases and expenses
    def calc_non_gst_inter_tax_amt
      0
    end


    def calc_totals(expenses, purchases)
      #sum of exempt inter expenses and purchases
      tax_amt = 0
      expenses.each do |expense|
        tax_amt += expense.sub_total
      end

      purchases.each do |purchase|
        tax_amt += purchase.sub_total
      end

      tax_amt
    end

end
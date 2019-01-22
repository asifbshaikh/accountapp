class Gstr3bSection61

  def initialize(section3, section4)
    @section3 = section3
    @section4 = section4
    @remaining_input_igst = @section4.net_igst_tax_amt
    @remaining_input_cgst = @section4.net_cgst_tax_amt
    @remaining_input_sgst = @section4.net_sgst_tax_amt
  end

  def igst_payable
    @igst_payable ||= @section3.outward_igst_tax_amt
  end

  def cgst_payable
    @cgst_payable ||= @section3.outward_cgst_tax_amt
  end

  def sgst_payable
    @sgst_payable ||= @section3.outward_sgst_tax_amt
  end

  def igst_paid_with_igst
    amt_paid = 0
    if @igst_payable >= @remaining_input_igst
      @igst_payable = @igst_payable - @remaining_input_igst
      amt_paid = @remaining_input_igst
      @remaining_input_igst = 0
    elsif @igst_payable < @remaining_input_igst
      amt_paid = @igst_payable
      @remaining_input_igst = @remaining_input_igst - amt_paid
      @igst_payable = 0
    end
    amt_paid 
  end

  def igst_paid_with_cgst
    return 0 if @igst_payable <=0

    amt_paid = 0
    if @igst_payable >= @remaining_input_cgst
      @igst_payable = @igst_payable - @remaining_input_cgst
      amt_paid = @remaining_input_cgst
      @remaining_input_cgst = 0
    elsif @igst_payable < @remaining_input_cgst
      amt_paid = @igst_payable
      @remaining_input_cgst = @remaining_input_cgst - amt_paid
      @igst_payable = 0
    end
    amt_paid 
  end

  def igst_paid_with_sgst
    return 0 if @igst_payable <=0

    amt_paid = 0
    if @igst_payable >= @remaining_input_sgst
      @igst_payable = @igst_payable - @remaining_input_sgst
      amt_paid = @remaining_input_sgst
      @remaining_input_sgst = 0
    elsif @igst_payable < @remaining_input_sgst
      amt_paid = @igst_payable
      @remaining_input_sgst = @remaining_input_sgst - amt_paid
      @igst_payable = 0
    end
    amt_paid 
  end

  def cgst_paid_with_cgst
    amt_paid = 0
    if @cgst_payable >= @remaining_input_cgst
      @cgst_payable = @cgst_payable - @remaining_input_cgst
      amt_paid = @remaining_input_cgst
      @remaining_input_cgst = 0
    elsif @cgst_payable < @remaining_input_cgst
      amt_paid = @cgst_payable
      @remaining_input_cgst = @remaining_input_cgst - amt_paid
      @cgst_payable = 0
    end
    amt_paid 
  end

  def cgst_paid_with_igst
    return 0 if @cgst_payable <=0

    amt_paid = 0
    if @cgst_payable >= @remaining_input_igst
      @cgst_payable = @cgst_payable - @remaining_input_igst
      amt_paid = @remaining_input_igst
      @remaining_input_igst = 0
    elsif @cgst_payable < @remaining_input_igst
      amt_paid = @cgst_payable
      @remaining_input_igst = @remaining_input_igst - amt_paid
      @cgst_payable = 0
    end
    amt_paid 
  end

  def sgst_paid_with_sgst
    amt_paid = 0
    if @sgst_payable >= @remaining_input_sgst
      @sgst_payable = @sgst_payable - @remaining_input_sgst
      amt_paid = @remaining_input_sgst
      @remaining_input_sgst = 0
    elsif @sgst_payable < @remaining_input_sgst
      amt_paid = @sgst_payable
      @remaining_input_sgst = @remaining_input_sgst - amt_paid
      @sgst_payable = 0
    end
    amt_paid 
  end

  def sgst_paid_with_igst
    return 0 if @sgst_payable <=0

    amt_paid = 0
    if @sgst_payable >= @remaining_input_igst
      @sgst_payable = @cgst_payable - @remaining_input_igst
      amt_paid = @remaining_input_igst
      @remaining_input_igst = 0
    elsif @sgst_payable < @remaining_input_igst
      amt_paid = @sgst_payable
      @remaining_input_igst = @remaining_input_igst - amt_paid
      @sgst_payable = 0
    end
    amt_paid 
  end

  def balance_igst_paid_in_cash
    @igst_payable - @remaining_input_igst
  end

  def balance_cgst_paid_in_cash
    @cgst_payable - @remaining_input_cgst
  end

  def balance_sgst_paid_in_cash
    @sgst_payable - @remaining_input_sgst
  end

end
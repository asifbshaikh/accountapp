class HsnData
  def initialize(num,hsn_cd,desc,uqc,qty,val,txval,iamt,camt,samt)
    @num = num
    @hsn_cd = hsn_cd
    @desc = desc
    uqc.blank? ? @uqc= "" : @uqc= uqc
    @qty = qty
    @val = val
    @txval= txval
    @iamt = iamt
    @camt = camt
    @samt= samt
  end

  def add_value(val)
    @val += val
  end

  def add_txval(txval)
    @txval += txval
  end

  def add_qty(qty)
    @qty += qty
  end


  def add_iamt(iamt)
    @iamt += iamt

  end

  def add_camt(camt)
    @camt += camt

  end

  def add_samt(samt)
    @samt += samt
  end

  def iamt
    if @iamt != 0 
      @iamt.to_f.round(2)
    end 
  end

  def camt
    if @camt != 0 
      @camt.to_f.round(2)
    end 
  end

  def samt
    if @samt != 0 
      @samt.to_f.round(2)
    end 
  end

end
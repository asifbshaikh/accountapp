class GstInvoiceLineItem
  attr_accessor :rt, :tx_val , :iamt, :camt, :samt

  def initialize(rate, txn_value, igst_amt, cgst_amt, sgst_amt, pos)
    @rt = rate
    @txval = txn_value
    @iamt = igst_amt
    @camt = cgst_amt
    @samt = sgst_amt
    @pos = pos
  end

  def add_txn_value(txn_val)
    @txval += txn_val
  end

  def add_igst_amt(igst_amt)
    @iamt += igst_amt
  end

  def add_cgst_amt(cgst_amt)
     @camt += cgst_amt
  end

  def add_sgst_amt(sgst_amt)
    @samt += sgst_amt
  end

  def rt
    @rt.to_f
  end

  def txval
    @txval.to_f
  end

  def pos=(pos)
    @pos = pos
  end

  def pos
    @pos
  end


end
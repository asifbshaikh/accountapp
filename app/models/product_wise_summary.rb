class ProductWiseSummary
  attr_accessor :rt, :tx_val , :iamt, :camt, :samt

  def initialize(hsn_sc,desc,uqc,qty,txn_value, igst_amt, cgst_amt, sgst_amt)
    @hsn_sc = hsn_sc
    @desc =desc
    @uqc = uqc
    @qty = qty
    @val = txn_value + igst_amt + cgst_amt + sgst_amt
    @txval = txn_value
    @iamt = igst_amt
    @camt = cgst_amt
    @samt = sgst_amt
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


end
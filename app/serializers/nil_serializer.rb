class NilSerializer < InvoiceSerializer
  # attributes :inum, :idt,:val,:pos,:rchrg,:etin,:inv_typ, :items
  attributes :sply_ty,:expt_amount,:nil_amt,:ngsup_amt

  def attributes
    hash = super
    hash.each {|key, value|
      if value.nil?
        hash.delete(key)
      end
    }
    hash
  end


def sply_ty
end


def expt_amount
end



def nil_amt
end


def ngsup_amt
end


end

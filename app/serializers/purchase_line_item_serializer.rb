class PurchaseLineItemSerializer < ActiveModel::Serializer
  # attributes :itm_det
  attributes :rt ,:txval,:iamt,:camt,:samt,:csamt


  def attributes
     hash = super
     hash.each {|key, value|
      if value.nil?
        hash.delete(key)
     end
    }
    hash
   end


  # def num

  # end



  def itm_det

    { :rt => rt ,
      :txval => txval,
      :iamt => iamt,
      :camt => camt,
      :samt => samt,
      :csamt => csamt
    }

  end




  def rt
    object.tax_accounts.first.accountable.tax_rate.to_f
  end

  def txval
    object.amount.to_f
  end


  def iamt
   object.igst_amt.eql?(0) ? nil : object.igst_amt.to_f
  end

  def camt
     object.cgst_amt.eql?(0) ? nil : object.cgst_amt.to_f

  end

  def samt
    object.sgst_amt.eql?(0) ? nil : object.sgst_amt.to_f  
  end


  def csamt
   
 end

end

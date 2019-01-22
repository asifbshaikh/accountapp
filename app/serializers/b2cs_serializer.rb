class B2csSerializer < InvoiceSerializer
  attributes :flag,:sply_ty, :rt, :typ,:etin, :pos, :txval, :iamt, :csamt,:camt, :samt



  def attributes
     hash = super
     hash.each {|key, value|
      if value.nil?
        hash.delete(key)
     end
    }
    hash
   end



def flag

end

 def sply_ty
  'OE'
 	
 end


 def rt
 	
 end


 def typ
 

 end

 def etin
 	

 end


 def pos

 end

 def txval

 end

 def iamt

 end


 def csamt


 end

 def camt
 end

 def samt

 end


end

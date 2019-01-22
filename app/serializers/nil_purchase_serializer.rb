class Gstr2B2bSerializer <  PurchaseSerializer

attributes :inter, :intra 

  def attributes
    hash = super
    hash.each {|key, value|
      if value.nil?
        hash.delete(key)
      end
    }
    hash
  end


def inter
  
end

def intra
  
end


end
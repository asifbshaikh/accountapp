class ChangeDataTypeForEstimateLineItemsTax < ActiveRecord::Migration
 def self.up
     change_table :estimate_line_items do |t|
      t.change :tax, :boolean
    end
  end

  def self.down
   change_table :estimate_line_items do |t|
      t.change :tax, :decimal
    end
  end
end  
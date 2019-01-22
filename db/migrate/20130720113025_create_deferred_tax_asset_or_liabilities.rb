class CreateDeferredTaxAssetOrLiabilities < ActiveRecord::Migration
  def self.up
    create_table :deferred_tax_asset_or_liabilities do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :deferred_tax_asset_or_liabilities
  end
end

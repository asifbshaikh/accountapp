class CreateGstActions < ActiveRecord::Migration
  def change
  	create_table :gst_actions do |t|
      t.string :action
      t.string :url
      t.string :version
      t.string :gst_retrun_type
      t.string :description

      t.timestamps
     end
  end

end

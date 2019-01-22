class CreateExportPortCodes < ActiveRecord::Migration
  def change
    create_table :export_port_codes do |t|

    	t.string :port_code
    	t.string :description
   
      t.timestamps
    end
  end
end

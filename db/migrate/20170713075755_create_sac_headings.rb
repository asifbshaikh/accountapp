class CreateSacHeadings < ActiveRecord::Migration
  def change
    create_table :sac_headings do |t|
      t.integer :heading_index
      t.string  :heading
      t.timestamps
    end
  end
end

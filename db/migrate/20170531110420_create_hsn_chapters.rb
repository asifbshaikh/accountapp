class CreateHsnChapters < ActiveRecord::Migration
  def change
    create_table :hsn_chapters do |t|
      t.integer :chapter_index
      t.string :chapter_heading
      t.timestamps
    end
  end
end

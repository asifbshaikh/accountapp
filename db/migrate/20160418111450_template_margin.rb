class TemplateMargin < ActiveRecord::Migration
  def change
    create_table :template_margins do |t|
      t.integer :template_id
      t.integer :hide_logo,:default=>0
      t.integer :hide_address,:default=>0
      t.decimal :top_margin,:default=>10
      t.decimal :left_margin,:default=>10
      t.decimal :right_margin,:default=>20
 
      t.timestamps
    end
  end
end

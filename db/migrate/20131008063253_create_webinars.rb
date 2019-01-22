class CreateWebinars < ActiveRecord::Migration
  def change
    create_table :webinars do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.date :date
      t.string :city
      t.text :detail

      t.timestamps
    end
  end
end

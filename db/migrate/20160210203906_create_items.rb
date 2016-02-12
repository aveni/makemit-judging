class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
    	t.integer :number
    	t.string :link

      t.string :name
      t.string :blurb
    	t.string :pic_url
   	  
      t.float :mu
      t.float :sigma_sq
      
      t.timestamps null: false
    end
  end
end

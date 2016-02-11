class CreateDecisions < ActiveRecord::Migration
  def change
    create_table :decisions do |t|

  	  t.belongs_to :winner
			t.belongs_to :loser
			t.belongs_to :judge
			
      t.timestamps null: false
    end
  end
end

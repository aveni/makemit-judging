class CreateJoinTableJudgeItem < ActiveRecord::Migration
  def change
    create_join_table :judges, :items do |t|
      # t.index [:judge_id, :item_id]
      # t.index [:item_id, :judge_id]
    end
  end
end

class Decision < ActiveRecord::Base

		belongs_to :winner, :class_name => 'Item'
	  belongs_to :loser, :class_name => 'Item'
	  belongs_to :judge

	  validates :winner, presence: true
	  validates :loser, presence: true
	  validates :judge, presence: true

end

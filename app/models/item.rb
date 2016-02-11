class Item < ActiveRecord::Base


	has_many :wins, :class_name => 'Decision', :foreign_key => 'winner_id'
    has_many :losses, :class_name => 'Decision', :foreign_key => 'loser_id'

	validates :name, presence: true, uniqueness: true
	validates :number, presence: true, uniqueness: true
	validates :link, presence: true, uniqueness: true
	validates :blurb, presence: true

end

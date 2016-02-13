class Item < ActiveRecord::Base


	has_many :wins, :class_name => 'Decision', :foreign_key => 'winner_id'
    has_many :losses, :class_name => 'Decision', :foreign_key => 'loser_id'
    has_and_belongs_to_many :judges 

	validates :name, presence: true, uniqueness: true
	validates :number, presence: true, uniqueness: true
	validates :link, presence: true, uniqueness: true
	validates :blurb, presence: true

	validates :mu, presence: true
	validates :sigma_sq, presence: true

end

class Judge < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable


    belongs_to :prev, :class_name => 'Item'
    belongs_to :next, :class_name => 'Item'

    has_many :decisions
    has_and_belongs_to_many :items
end

class JudgesController < ApplicationController
  before_filter :verify_owner, :only=>:show

  def show
  	@judge = Judge.find(params[:id])
  end

  def verify_owner
    if !current_judge || params[:id] != "#{current_judge.id}"
    	redirect_to root_path, alert: "Cannot access that page."
    end
  end  
end

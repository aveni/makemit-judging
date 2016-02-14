class JudgesController < ApplicationController
  before_filter :verify_owner, :only =>[:show, :vote]
  include ApplicationHelper

  def show
    if current_judge
  	 @judge = Judge.find(params[:id])
    else
      redirect_to root_path, alert: "Cannot access that page."
    end
  end

  def index
    if current_judge and current_judge.email == "team@makemit.org"
      @judges = Judge.all
      @items = Item.all.order(mu: :desc)
    else
      redirect_to root_path, alert: "Cannot access that page."
    end
  end

  def start
    if current_judge and current_judge.email == "team@makemit.org"
      startJudging
      redirect_to judges_path
    else
      redirect_to root_path, alert: "Cannot access that page."
    end
  end

  def vote
  	annotator = current_judge
  	if annotator != nil
  		if params[:choice] == "Skip"
            annotator.items << annotator.next
      else
          if params[:choice] == "Previous"
              perform_vote(annotator, false)
              decision = Decision.new(judge_id: annotator.id, winner_id:annotator.prev.id, loser_id: annotator.next.id)
              decision.save
          elsif params[:choice] == "Current"
              perform_vote(annotator, true)
              decision = Decision.new(judge_id: annotator.id, winner_id:annotator.next.id, loser_id: annotator.prev.id)
              decision.save
          end
          annotator.prev = annotator.next
          annotator.items << annotator.prev
      end
      annotator.next = choose_next(annotator)
      annotator.save
      redirect_to judge_path(current_judge)
    else
      redirect_to root_path, alert: "Not allowed!"
    end
  end

  def verify_owner
    if !current_judge || params[:id] != "#{current_judge.id}"
    	redirect_to root_path, alert: "Cannot access that page."
    end
  end  
end

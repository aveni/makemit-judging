module ApplicationHelper
	include Math

    def betaln(a,b)
    	log((gamma(a)*gamma(b)/gamma(a+b)).abs)
    end

    def psi(x)
    	tops = [-1,-1,1,-1,1,-5,691,-1]
    	bots = [2,12,120,252,240,660,32760,12]
    	exps = [1,2,4,6,8,10,12,14]
    	sum = 0
    	for i in 0..7
    		puts sum
    		sum += Float(tops[i])/(bots[i]*(Float(x)**exps[i]))
    	end
    	sum + log(x)
    end

	# via https://en.wikipedia.org/wiki/Normal_distribution
	def divergence_gaussian(mu_1, sigma_sq_1, mu_2, sigma_sq_2)
	    ratio = (sigma_sq_1 / sigma_sq_2)
	    (mu_1 - mu_2) ** 2 / (2 * sigma_sq_2) + (ratio - 1 - log(ratio)) / 2
    end

	# via https://en.wikipedia.org/wiki/Beta_distribution
	def divergence_beta(alpha_1, beta_1, alpha_2, beta_2)
	    return betaln(alpha_2, beta_2) - betaln(alpha_1, beta_1) + 
	    (alpha_1 - alpha_2) * psi(alpha_1) + 
	    (beta_1 - beta_2) * psi(beta_1) + 
	    (alpha_2 - alpha_1 + beta_2 - beta_1) * psi(alpha_1 + beta_1)
	end

	# returns new (alpha, beta, mu_winner, sigma_sq_winner, mu_loser, sigma_sq_loser)
	def update(alpha, beta, mu_winner, sigma_sq_winner, mu_loser, sigma_sq_loser)
	    (updated_alpha, updated_beta, _) = _updated_annotator(alpha, beta, mu_winner, sigma_sq_winner, mu_loser, sigma_sq_loser)
	    (updated_mu_winner, updated_mu_loser) = _updated_mus(alpha, beta, mu_winner, sigma_sq_winner, mu_loser, sigma_sq_loser)
	    (updated_sigma_sq_winner, updated_sigma_sq_loser) = _updated_sigma_sqs(alpha, beta, mu_winner, sigma_sq_winner, mu_loser, sigma_sq_loser)
	    
	    [updated_alpha, updated_beta, updated_mu_winner, updated_sigma_sq_winner, updated_mu_loser, updated_sigma_sq_loser]
	end

	def expected_information_gain(alpha, beta, mu_a, sigma_sq_a, mu_b, sigma_sq_b)
	    (alpha_1, beta_1, c) = _updated_annotator(alpha, beta, mu_a, sigma_sq_a, mu_b, sigma_sq_b)
	    (mu_a_1, mu_b_1) = _updated_mus(alpha, beta, mu_a, sigma_sq_a, mu_b, sigma_sq_b)
	    (sigma_sq_a_1, sigma_sq_b_1) = _updated_sigma_sqs(alpha, beta, mu_a, sigma_sq_a, mu_b, sigma_sq_b)
	    prob_a_ranked_above = c
	    (alpha_2, beta_2, _) = _updated_annotator(alpha, beta, mu_b, sigma_sq_b, mu_a, sigma_sq_a)
	    (mu_b_2, mu_a_2) = _updated_mus(alpha, beta, mu_b, sigma_sq_b, mu_a, sigma_sq_a)
	    (sigma_sq_b_2, sigma_sq_a_2) = _updated_sigma_sqs(alpha, beta, mu_b, sigma_sq_b, mu_a, sigma_sq_a)


        prob_a_ranked_above * (
            divergence_gaussian(mu_a_1, sigma_sq_a_1, mu_a, sigma_sq_a) +
            divergence_gaussian(mu_b_1, sigma_sq_b_1, mu_b, sigma_sq_b) + 
            GAMMA * divergence_beta(alpha_1, beta_1, alpha, beta)) +
    	(1 - prob_a_ranked_above) * (
            divergence_gaussian(mu_a_2, sigma_sq_a_2, mu_a, sigma_sq_a) +
            divergence_gaussian(mu_b_2, sigma_sq_b_2, mu_b, sigma_sq_b) + 
            GAMMA * divergence_beta(alpha_2, beta_2, alpha, beta))
    end

	# returns (updated mu of winner, updated mu of loser)
	def _updated_mus(alpha, beta, mu_winner, sigma_sq_winner, mu_loser, sigma_sq_loser)
	    mult = (alpha * exp(mu_winner)) / (alpha * exp(mu_winner) + beta * exp(mu_loser)) -
	            (exp(mu_winner)) / (exp(mu_winner) + exp(mu_loser))
	    updated_mu_winner = mu_winner + sigma_sq_winner * mult
	    updated_mu_loser = mu_loser - sigma_sq_loser * mult

	    [updated_mu_winner, updated_mu_loser]
	end

	# returns (updated sigma squared of winner, updated sigma squared of loser)
	def _updated_sigma_sqs(alpha, beta, mu_winner, sigma_sq_winner, mu_loser, sigma_sq_loser)
	    mult = (alpha * exp(mu_winner) * beta * exp(mu_loser)) /
	            ((alpha * exp(mu_winner) + beta * exp(mu_loser)) ** 2) -
	            (exp(mu_winner) * exp(mu_loser)) / ((exp(mu_winner) + exp(mu_loser)) ** 2)

	    updated_sigma_sq_winner = sigma_sq_winner * [1 + sigma_sq_winner * mult, KAPPA].max
	    updated_sigma_sq_loser = sigma_sq_loser * [1 + sigma_sq_loser * mult, KAPPA].max

	    [updated_sigma_sq_winner, updated_sigma_sq_loser]
	end

	# returns (updated alpha, updated beta, pr i >k j which is c)
	def _updated_annotator(alpha, beta, mu_winner, sigma_sq_winner, mu_loser, sigma_sq_loser)
	    c_1 = exp(mu_winner) / (exp(mu_winner) + exp(mu_loser)) + 0.5 *
	            (sigma_sq_winner + sigma_sq_loser) *
	            (exp(mu_winner) * exp(mu_loser) * (exp(mu_loser) - exp(mu_winner))) /
	            ((exp(mu_winner) + exp(mu_loser)) ** 3)
	    c_2 = 1 - c_1
	    c = (c_1 * alpha + c_2 * beta) / (alpha + beta)

	    expt = (c_1 * (alpha + 1) * alpha + c_2 * alpha * beta) /
	            (c * (alpha + beta + 1) * (alpha + beta))
	    expt_sq = (c_1 * (alpha + 2) * (alpha + 1) * alpha + c_2 * (alpha + 1) * alpha * beta) /
	            (c * (alpha + beta + 2) * (alpha + beta + 1) * (alpha + beta))

	    variance = (expt_sq - expt ** 2)
	    updated_alpha = ((expt - expt_sq) * expt) / variance
	    updated_beta = (expt - expt_sq) * (1 - expt) / variance

	    [updated_alpha, updated_beta, c]
	end

	######################################

	def choose_next(annotator)
	    items = Item.all.where("id NOT IN (?)", annotator.item_ids)
	    items = items.shuffle
	    if items
	        if rand() < EPSILON
	            items[0]
	        else
	        	prev = annotator.prev
	            items.max_by{|i| expected_information_gain(
	                annotator.alpha,
	                annotator.beta,
	                prev.mu,
	                prev.sigma_sq,
	                i.mu,
	                i.sigma_sq)}
	        end
	    else
	        nil
	    end
    end

    def perform_vote(annotator, next_won)
    	if next_won
        	winner = annotator.next
        	loser = annotator.prev
	    else
	        winner = annotator.prev
	        loser = annotator.next
	    end
	    u_alpha, u_beta, u_winner_mu, u_winner_sigma_sq, u_loser_mu, u_loser_sigma_sq = update(
	        annotator.alpha,
	        annotator.beta,
	        winner.mu,
	        winner.sigma_sq,
	        loser.mu,
	        loser.sigma_sq)
	    annotator.alpha = u_alpha
	    annotator.beta = u_beta
	    winner.mu = u_winner_mu
	    winner.sigma_sq = u_winner_sigma_sq
	    loser.mu = u_loser_mu
	    loser.sigma_sq = u_loser_sigma_sq

	    annotator.save
	    winner.save
	    loser.save
	end

	def resetAll()
		Item.all.each do |i|
			i.mu = MU_PRIOR
			i.sigma_sq = SIGMA_SQ_PRIOR
			i.judges = []
			i.save
		end

		Judge.all.each do |j|
			j.alpha = ALPHA_PRIOR
			j.beta = BETA_PRIOR
			j.items = []
			j.prev_id = nil
			j.next_id = nil
			j.save
		end

		Decision.all.each do |d|
			d.destroy
		end
	end

	def startJudging()
		Judge.all.where(prev_id:nil, next_id:nil).each do |j|
			j.alpha = ALPHA_PRIOR
			j.beta = BETA_PRIOR
			j.items = []
			j.prev = Item.all.sample(1)[0]
			j.items << j.prev
			j.next = choose_next(j)
			j.save
		end
	end


end

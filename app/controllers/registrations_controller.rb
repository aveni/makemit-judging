class RegistrationsController < Devise::RegistrationsController
  # def new
  #   redirect_to root_path, alert: 'Cannot create judge account.'
  # end

  # def create
  #   redirect_to root_path, alert: 'Cannot create judge account.'
  # end

  def create
    super do
        resource.alpha = ALPHA_PRIOR
        resource.beta = BETA_PRIOR
        resource.save
    end
  end

end

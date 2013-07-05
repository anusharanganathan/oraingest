class Ability
  include CanCan::Ability # We can remove this once we're using Hydra-head 5.2.0+

  include Hydra::Ability

  def custom_permissions
    alias_action :apply, :to => :update
    
    if @user.reviewer?
      can :review, GenericFile    # grant permission to review submissions
    end

  end
end
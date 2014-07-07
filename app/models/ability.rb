class Ability
  include Hydra::Ability
  
  # Define any customized permissions here.
  def custom_permissions
    cannot :download, ActiveFedora::Datastream
    cannot :show, CourseCollection
    cannot :show, PersonalCollection

    alias_action :append_to, :remove_from, to: :update

    if current_user.registered?
      can :download, ActiveFedora::Datastream
      can :show, CourseCollection
      can [:create, :show], PersonalCollection

      can :read, TuftsImage
    end

    if current_user.admin?
      can :manage, CourseCollection
    end
  end

end

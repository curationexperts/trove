class Ability
  include Hydra::Ability
  
  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end

    cannot :download, ActiveFedora::Datastream
    cannot :show, CourseCollection
    cannot :show, PersonalCollection

    if current_user.registered?
      can :download, ActiveFedora::Datastream
      can :show, CourseCollection
      can [:create, :show], PersonalCollection

      can :append_to, PersonalCollection do |pc|
        pc.edit_users.include?(current_user.user_key)
      end
    end

    if current_user.admin?
      can [:create, :append_to], CourseCollection
    end
  end

end

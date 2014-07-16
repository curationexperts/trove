class Ability
  include Hydra::Ability
  

  def read_permissions
    if current_user.registered?
       can :read, CourseCollection
       can :read, PersonalCollection do |obj|
         test_read(obj.id)
       end

       can :read, TuftsImage
    end
  end

  def custom_permissions
    if current_user.admin?
      can :manage, [CourseCollection, CourseCollectionSolrProxy, PersonalCollection,
                    PersonalCollectionSolrProxy]
    else
      cannot :index, PersonalCollection
    end
  end

  def edit_permissions
    alias_action :append_to, :remove_from, to: :update
    if current_user.registered?
      can [:update], [PersonalCollection, PersonalCollectionSolrProxy] do |proxy|
        test_edit(proxy.id)
      end
    end
  end

  def create_permissions
    can :create, PersonalCollection if current_user.registered?
  end

  def download_permissions
    can :download, ActiveFedora::Datastream if current_user.registered?
  end

end

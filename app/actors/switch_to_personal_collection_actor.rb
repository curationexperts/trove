class SwitchToPersonalCollectionActor < SwitchTypeActor

  def to_type
    PersonalCollection
  end

  def find_new_parent
    User.find_by_user_key(@collection.creator).personal_collection(true)
  end
end

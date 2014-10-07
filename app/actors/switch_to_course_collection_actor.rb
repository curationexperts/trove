class SwitchToCourseCollectionActor < SwitchTypeActor

  def to_type
    CourseCollection
  end

  def find_new_parent
    CourseCollection.root
  end
end

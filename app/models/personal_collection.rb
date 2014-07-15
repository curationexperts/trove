class PersonalCollection < CuratedCollection
  include WithNestedMembers

  # Sets the default value for the edit form.
  def type
    'personal'
  end

  def creator
    super.first
  end
end

class PersonalCollection < CuratedCollection

  # Sets the default value for the edit form.
  def type
    'personal'
  end

  def creator
    super.first
  end
end

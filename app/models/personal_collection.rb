class PersonalCollection < CuratedCollection
  def type
    'personal'
  end

  def type= val
    # TODO, this casts to whatever they set
  end

  def creator
    super.first
  end
end

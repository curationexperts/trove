class CourseCollection < CuratedCollection
  def type
    'course'
  end

  def type= val
    # TODO, this casts to whatever they set
  end

  def creator
    super.first
  end
end

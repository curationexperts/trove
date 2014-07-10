class CourseCollection < CuratedCollection

  # Sets the default value for the edit form.
  def type
    'course'
  end

  def creator
    super.first
  end


end

class CourseCollection < CuratedCollection
  include WithNestedMembers

  after_create :add_to_root_collection

  def add_to_root_collection
    return if root?
    CourseCollection.root.tap do |root|
      root.members << self
      root.save!
    end
  end

  # Sets the default value for the edit form.
  def type
    'course'
  end

  def creator
    super.first
  end

  # TODO this is slow (loads every object, even TuftsImages) and could be optimized.
  def collection_members
    @collection_members ||= members.select { |member| member.is_a? CourseCollection }
  end

  ROOT_PID = 'tufts:root_collection'

  def root?
    self.pid == ROOT_PID
  end

  class << self
    def root
      root = CourseCollection.where(id: ROOT_PID).first
      root ||= CourseCollection.create!(pid: ROOT_PID, title: 'Root')
    end
  end


end

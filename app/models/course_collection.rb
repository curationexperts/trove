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

  def to_solr(solr_doc=Hash.new)
    super.tap do |solr_doc|
      solr_doc['member_ids_ssim'] = member_ids.to_a.map(&:value)
    end
  end
end

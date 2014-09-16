
module Tufts
  class ModelNotAsserted < RuntimeError; end
end

module ValidateRelationship
  # Ensure that the model we're trying to load is a type it can be cast to.
  def load_from_fedora(pid, cast)
    super.tap do |obj|
      raise Tufts::ModelNotAsserted, "#{obj.class} is not in the has_model assertion for #{pid}" unless ActiveFedora::ContentModel.known_models_for(obj).include? obj.class
    end
  end
end

ActiveFedora::Relation.send(:prepend, ValidateRelationship)

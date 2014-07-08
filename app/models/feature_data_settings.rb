class FeatureDataSettings < Settingslogic
  source "#{Rails.root}/config/feature_data.yml"
  namespace Rails.env
end

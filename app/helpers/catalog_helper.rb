module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def featured_records
    pids = FeatureDataSettings['featured_pids']
    if pids.present?
      ActiveFedora::Base.find(pids, cast: true)
    else
      TuftsImage.where(displays_ssim: 'tdil').limit(3)
    end
  end

end

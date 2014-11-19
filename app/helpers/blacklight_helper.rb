module BlacklightHelper

  include Hydra::BlacklightHelperBehavior


  def render_search_bar
    super unless controller_name.in?(['sessions'])
  end

end
class PagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:about, :contact]

  def about
  end

  def contact
  end
end

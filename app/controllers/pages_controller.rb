class PagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:about, :contact, :help]

  def about
  end

  def contact
  end

  def help
  end
end

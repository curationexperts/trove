class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  include Tufts::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    user_key
  end

  def personal_collection
    root = PersonalCollection.where(id: root_pid).first
    root ||= PersonalCollection.create!(pid: root_pid, title: "Collections for #{self}")
  end

  private
    def root_pid
      "tufts.uc:personal_#{user_key.gsub(/@/, '_')}"
    end
end

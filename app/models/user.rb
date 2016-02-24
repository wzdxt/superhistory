class User < ActiveRecord::Base
  establish_connection :user
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # , :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :encryptable, :timeoutable
end

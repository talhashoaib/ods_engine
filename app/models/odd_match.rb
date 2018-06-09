class OddMatch < ActiveRecord::Base
	has_many :asian_handicaps, dependent: :destroy
end

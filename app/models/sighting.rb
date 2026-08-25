class Sighting < ApplicationRecord
  belongs_to :report
  belongs_to :user
  belongs_to :location

  enum :status, Report::STATUSES

  validates :location, presence: true
end

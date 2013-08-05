class Weight < ActiveRecord::Base
  belongs_to :user

  def fat_mass
    fat_percent && (weight * fat_percent).round / 100.0
  end

  def lean_mass
    fat_percent && ((weight - fat_mass) * 100.0).round / 100.0
  end
end

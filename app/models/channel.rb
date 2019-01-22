class Channel < ActiveRecord::Base
  has_many :leads
  scope :active, where(active: true) 
  validates_presence_of :channel_name

  def status
    if active?
      "Active"
    else
      "Inactive"
    end
  end

  def mark_inactive
    update_attributes(active: false)
  end

  def mark_active
    update_attributes(active: true)
  end

  def self.list_channel_options 
    Channel.where(active: true).select("id, channel_name").map {|x| [x.id, x.channel_name] }
  end

  def self.channel_names
    channels = self.all
    arr=[]
    channels.each do |channel|
      hash={}
      hash["id"]=channel.id 
      hash["channel_name"]=channel.channel_name
      arr<<hash
    end
    arr.to_json
  end

end

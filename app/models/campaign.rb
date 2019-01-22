class Campaign < ActiveRecord::Base
  has_many :leads
  validates_presence_of :campaign_name, :start_date, :end_date
   def self.list_campaign_options 
    Campaign.select("id, campaign_name").map {|x| [x.id, x.campaign_name] }
  end

  def self.campaign_names
      campaign = self.all
      arr=[]
      campaign.each do |campaign|
        hash={}
        hash["id"]=campaign.id 
        hash["campaign_name"]=campaign.campaign_name
        arr<<hash
      end
      arr.to_json
    end

end

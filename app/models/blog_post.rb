class BlogPost < ActiveRecord::Base
  paginates_per 10
  belongs_to :blog_categories

  validates :slug, :uniqueness => true, :presence => true
  validates :author, :description,:blog_category_id ,:presence => true
  before_validation :generate_slug

  scope :published_posts, lambda {|status| where(:status => 0)}


  def to_param
    slug
  end

  def generate_slug
    self.slug ||= title.parameterize
  end

  # def author
  #   SuperUser.find(self.super_user_id).first_name
  # end
  def get_gplus_add
    if author == "Harshal Katre"
          "+HarshalKatreLive"
    elsif author == "Mohnish Katre"
         "112759616665746477645" 
    elsif author == "Amit Mahalle" 
         "101451144776308208845"
    end 
  end
  def blog_status
    self.status == 0 ? "Published" : "Draft" 
  end

  def category
    BlogCategory.find(self.blog_category_id).title
  end

  def word_count
    self.content.scan(/[\w-]+/).size unless content.blank?
  end

end

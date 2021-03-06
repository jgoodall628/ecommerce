class Product < ActiveRecord::Base
  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  belongs_to :category

  searchable do
    text :name
    text :brand
    text :description
    text :category do
      category.name
    end
  end

  has_many :line_items


end

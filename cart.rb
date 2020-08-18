require "json"
require "pry"

class Checkout
  attr_accessor :code, :offer, :name, :price, :products, :cart

  def initialize
    self.products = parsed_products
    self.cart = []
  end

  # Here, im loading and parsing JSON
  def parsed_products
    products_file = File.read('products.json')
    JSON.parse(products_file)["products"]
  end

  #Here, im scanning code of product into an array
  def scan(code)
    @cart.push(code)
  end

  #method of getting a $n discount when buying more than two items, like a T-shirt
  def bulk_total(product, count)
    count > 2 ? count * (product['price']-product['discount']) : count * product['price']
  end

  #method of getting a discount two for one
  def two_for_one_total(product, count)
    count %2 == 0 ? ( count / 2 ) * product['price'] : ( count / 2 ).next * product['price']
  end

  #method of getting a price without discounts
  def standart_total(product, count)
    product['price'] * count
  end

  #method of getting the total price
  def total
    #Here, im grouping the scanned product code
    grouped_cart = cart.group_by(&:to_s)
    hashed_cart = {}
    #Here, im making a hash from the product code and quantity
    grouped_cart.each { |k, v| hashed_cart[k] = v.count }
    sum = 0
    hashed_cart.each do |code, count|
      #Here, im getting product data by product code
      product = products.find { |p|  p['code'] == code }
      next unless product.any?
      #Here, im checking which offer the product has
      sum += case product['offer']
             when 'bulk'
               bulk_total(product, count)
             when '2f1'
               two_for_one_total(product, count)
             else
               standart_total(product, count)
             end
    end
    sum
  end
end

#our order list for counting
examples = [
  {
    items: ["VOUCHER", "TSHIRT", "MUG"],
    total: 32.50
  },
  {
    items: ["VOUCHER", "TSHIRT", "VOUCHER"],
    total: 25
  },
  {
    items: ["TSHIRT", "TSHIRT", "TSHIRT","VOUCHER","TSHIRT"],
    total: 81
  },
  {
    items: ["VOUCHER", "TSHIRT", "VOUCHER", "VOUCHER", "MUG", "TSHIRT", "TSHIRT"],
    total: 74.50
  }
]

#Here, im comparing the result of the examples and the result of the total method
def assert_equal(value1, value2)
  if value1 == value2
    puts "Test Example Is Corect"
  else
    puts "Test Example Failed"
  end
end

#Here, im crateting objects of the class Checkout and finding total price
examples.each do |example|
  co = Checkout.new
  example[:items].each do |item|
    #Here, im scanning code of product into an array
    co.scan(item)
  end
  #Here, im comparing results
  assert_equal(co.total, example[:total])
  puts "co.total: #{co.total}"
  puts "example: #{example[:total]}"
end
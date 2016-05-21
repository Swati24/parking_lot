module HelperMethods
  def generate_car_number
    "#{alphabets_combination(2)}-#{numbers_combination(3)}-#{alphabets_combination(2)}-#{numbers_combination(5)}"
  end

  def numbers_combination(length)
  	rand.to_s[2..length]
  end

  def alphabets_combination(length)
  	(0...length).map { (65 + rand(26)).chr }.join
  end

  def get_colour_randomly
  	['White' 'Black', 'Blue', 'Red'].sample
  end

  def park_command(options = {})
    car_number = options[:car_number] || generate_car_number
    colour = options[:colour] || get_colour_randomly
  	"park #{car_number} #{colour}"
  end
end

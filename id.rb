#!/Users/gawain.reifsnyder/.rvm/rubies/ruby-2.2.2/bin/ruby

class ImageTester
  def initialize
    files = `ls `.split(" ")
    images = assemble(files)
    add_ratio(images)

    Calculator.calc_ratio(images)
    puts images
  end

private

  def add_ratio(images)
    images.each do |img|
      img[:ratio] = (img[:size].to_f / (img[:width].to_f * img[:height].to_f)).round(3)
    end
  end

  def assemble(files)
    image_data = []
    files.collect do |f|
      if File.extname(f) == ".jpg" || File.extname(f) == ".png"
        cmd = "magick identify -format \"%w %H %m %b %f\" \"#{f}\""
        params = `#{cmd}`.split(" ")
        if !params.include?(nil)
          hsh = [[:width, params[0]], [:height, params[1]], [:type, params[2]], [:size, params[3]], [:file, params[4]]].to_h
        end
        image_data.push(hsh)
      end
    end
    image_data
  end
end

class Calculator
  ACCEPTABLE_MULTIPLIER = 1.2
  TOO_BIG_MULTIPLIER = 2

  def self.calc_ratio(images)
    images.each do |img|
      actual_ratio = img[:ratio]
      ideal_ratio = (8.3053*(img[:size].to_i ** -0.33)).round(3)
      acceptable_ratio = ideal_ratio * ACCEPTABLE_MULTIPLIER
      too_big = ideal_ratio * TOO_BIG_MULTIPLIER

      if(actual_ratio <= acceptable_ratio)
        img[:status] = "green"
      elsif(actual_ratio > acceptable_ratio && actual_ratio < too_big)
        img[:status] = "yellow"
      elsif(actual_ratio >= too_big)
        img[:status] = "red"
      end
    end
  end
end

hash_assembler = ImageTester.new

#!/Users/gawain.reifsnyder/.rvm/rubies/ruby-2.2.2/bin/ruby

class JpegTester
  IMAGE_PATH = "app/assets/images/".freeze
  def initialize
    files = `ls #{IMAGE_PATH}`.split(" ")
    @image_stats = assemble(files)
    Calculator.add_ratio(@image_stats)
    Calculator.calc_ratio(@image_stats)
  end

  def stats
    formatted_stats = compile_human_format_stats
    # return @image_stats
  end

private

  def assemble(files)
    image_data = []
    files.collect do |f|
      if File.extname(f) == ".jpg" || File.extname(f) == ".png"
        cmd = "magick identify -format \"%w %H %m %b %f\" \"#{IMAGE_PATH + f}\""
        params = `#{cmd}`.split(" ")
        if !params.include?(nil)
          hsh = [[:width, params[0]], [:height, params[1]], [:type, params[2]], [:size, params[3]], [:file, params[4]]].to_h
        end
        image_data.push(hsh)
      end
    end
    image_data
  end

  def compile_human_format_stats
    # sorted_hashes = @image_stats.sort_by { |hsh| hsh[:status] }
    green = []
    yellow = []
    red = []
    @image_stats.each do |img|
      if img[:status] == "green"
        green.push(img[:file])
      end
      if img[:status] == "yellow"
        yellow.push(img[:file])
      end
      if img[:status] == "red"
        red.push(img[:file])
      end
    end
    output_human_format_stats(green, yellow, red)
  end

  def output_human_format_stats(green, yellow, red)
    puts "\e[1;32m#{green.length} Optimally sized JPEG images found! Have a taco.\e[0m 🌮"
    puts "\e[1;36mCAUTION: #{yellow.length} borderline images found. Consider compressing these again from the original files.\e[0m"
    puts "\e[0;35m"
    puts yellow
    puts "\e[0m"
    puts "\e[1;31mWARNING: #{red.length} oversize images found. These must be compressed before committing. Sheesh, those things are huge!\e[0m"
    puts "\e[0;35m"
    puts red
    puts "\e[0m"
  end

end

class Calculator
  ACCEPTABLE_MULTIPLIER = 1.2.freeze
  TOO_BIG_MULTIPLIER = 2.freeze

  def self.add_ratio(images)
    images.each do |img|
      img[:ratio] = (img[:size].to_f / (img[:width].to_f * img[:height].to_f)).round(3)
    end
  end

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

#!/Users/gawain.reifsnyder/.rvm/rubies/ruby-2.2.2/bin/ruby

require 'csv'


class HashAssembler
  def initialize
    files = `ls `.split(" ")
    csv_string = ""
    calculator = Calculator.new
    files.collect do |f|
      if File.extname(f) == ".jpg" || File.extname(f) == ".png"
        cmd = "magick identify -format \"%w %H %m %b %f\" \"#{f}\""
        params = `#{cmd}`.split(" ")

        image_data = []
        if !params.include?(nil)
          hsh = [[:width, params[0]], [:height, params[1]], [:type, params[2]], [:size, params[3]], [:file, params[4]]].to_h

          # ratio = hsh[:size].to_f / (hsh[:width].to_f * hsh[:height].to_f)
          # hsh[:ratio] = ratio.round(3)

          pixels = hsh[:width].to_f * hsh[:height].to_f
          hsh[:pixels] = pixels.to_i

          ratio = calculator.ratio(pixels, hsh[:size])
          hsh[:ratio] = ratio

          image_data.push(hsh)
        end
      end
      # Write to csv
      csv_string += [pixels.to_i,ratio.round(3)].to_csv
      puts image_data
    end
  end
end

class Calculator
  def ratio(pixels, size)
    (size.to_f / pixels).round(3)
  end
end

hash_assembler = HashAssembler.new

# puts csv_string

class Mystring
  def self.mysub(string, pattern, replacement)
    result = string.gsub(pattern, replacement)
    puts "s: #{string}  p: #{pattern}  r: #{replacement}  = #{result}"
    result
  end
end

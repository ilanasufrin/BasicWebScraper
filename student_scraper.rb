require 'nokogiri'
require 'open-uri'


class Students
  attr_accessor :students, :student_index_page, :array_of_urls
  
  def initialize
    self.student_index_page = Nokogiri::HTML(open('http://ruby005.students.flatironschool.com/')) 
    self.students = {}
    index_scraper
    profile_scraper
  end 

  def index_scraper
    self.array_of_urls = [] #use collect for this & ||= for setting it 
    student_index_page.css("li.home-blog-post").each do |student|
      profile_url = student.css("div.blog-thumb a").attribute("href").value
      student_profile_url = Nokogiri::HTML(open("http://ruby005.students.flatironschool.com/#{profile_url}"))
      self.array_of_urls << student_profile_url
    end
  end 

  def profile_scraper #make a student class for scraping its own data and returning all their own data 
    self.array_of_urls.each do |url|
      name = url.css(".link-subs span").text
      students[name] = {
          :image => url.css(".student_pic").attribute("src").value,
          :bio => url.css(".services p").first.text.strip
        }
    end 
  end

end



class Cli
  attr_accessor :hash_of_students

  def initialize(hash)
    self.hash_of_students = hash
  end 

  def list_names 
    hash_of_students.keys.sort
  end 

  def find_name(name)
    student = hash_of_students.select do |student_name, attributes| 
      student_name.to_s == name
    end 
    print_attributes(student, name)
  end 

  def print_attributes(student, name)
    puts "\n#{name}'s attributes are:\n"

    student.each do |name, attributes|
      attributes.each do |attribute, value|
        puts "\n\s#{attribute.capitalize} - \s#{value}"
      end 
    end 
  end 

  def greeting
    puts "Welcome to our interface.  Here is a list of students in the class:"
    puts list_names
    puts "\nPlease type a name to see more info about that student"
    name = gets.strip
    find_name(name)
  end 

end 


def run 
#create students object and grab all student profiles
flatiron_students = Students.new
hash_of_students = flatiron_students.students
flatiron_students.profile_scraper

#initiate the Command Line Interface
cli = Cli.new(hash_of_students)
cli.greeting
end 




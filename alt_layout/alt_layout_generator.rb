# Alternative model generator using Rspec and Machinist. No fixtures.
class AltLayoutGenerator < Rails::Generator::NamedBase
  
  def manifest
    record do |m|
      m.directory 'app/views/layouts'
      m.template 'layout.html.haml', 
        File.join('app/views/layouts', "#{file_name}.html.haml")
    end
  end
  
end
# Alternative model generator using Rspec and Machinist. No fixtures.
class AltModelGenerator < Rails::Generator::NamedBase
  
  def initialize(runtime_args, runtime_options = {})
    super
    @destroy = (runtime_options[:command] == :destroy)
  end
  
  def manifest
    record do |m|
      create_dirs(m)
      create_model_and_spec(m)
      migrate(m)
      create_machinist_blueprint(m)
    end
  end
  
  private
  
  def create_dirs(m)
    m.directory File.join('app/models', class_path)
    m.directory File.join('spec/models', class_path)
  end
  
  def create_model_and_spec(m)
    m.template "model:model.rb", 
      File.join('app/models', class_path, "#{file_name}.rb")
    m.template 'model_spec.rb', 
      File.join('spec/models', class_path, "#{file_name}_spec.rb")
  end
  
  def migrate(m)
    unless options[:skip_migration]
      m.migration_template 'model:migration.rb', 'db/migrate', :assigns => {
        :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
    end
  end
  
  def create_machinist_blueprint(m)
    return if @destroy
    
    blueprints_path = File.join('spec', 'blueprints.rb')
    
    m.file "blueprints.rb", blueprints_path, :collision => :skip
    
    new_blueprint = "#{class_name}.blueprint do\n"
    attributes.each {|att| new_blueprint << "  #{att.name} { }\n"}
    new_blueprint << "end\n"
    
    m.gsub_file blueprints_path, /Sham(.*?)end/m do |match|
      "#{match}\n\n#{new_blueprint}"
    end
  end
  
end
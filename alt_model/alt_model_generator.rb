# Alternative model generator using Rspec and Machinist. No fixtures.
# Some stuff shamelessly ripped from rspec_model generator.
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
    m.template "model.rb", File.join('app/models', class_path, "#{file_name}.rb")
    m.template 'model_spec.rb', File.join('spec/models', class_path, "#{file_name}_spec.rb")
  end
  
  def migrate(m)
    migration_file_path = file_path.gsub(/\//, '_')
    migration_name = class_name
    
    if ActiveRecord::Base.pluralize_table_names
      migration_name = migration_name.pluralize
      migration_file_path = migration_file_path.pluralize
    end
    
    unless options[:skip_migration]
      m.migration_template 'migration.rb', 'db/migrate', :assigns => {
        :migration_name => "Create#{migration_name.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{migration_file_path}"
    end
  end
  
  def create_machinist_blueprint(m)
    return if @destroy
    
    blueprints_path = File.join('spec', 'blueprints.rb')
    
    unless File.exists?(destination_path(blueprints_path))
      m.file "blueprints.rb", blueprints_path
    end
    
    new_blueprint = "#{class_name}.blueprint do\n"
    attributes.each {|att| new_blueprint << "  #{att.name} { }\n"}
    new_blueprint << "end\n"
    
    m.gsub_file blueprints_path, /Sham(.*?)end/m do |match|
      "#{match}\n\n#{new_blueprint}"
    end
  end
  
end
namespace :restapi do
  desc "Generate static documentation"
  task :static => :environment do

    av = ActionView::Base.new(ActiveSupport::Dependencies.autoload_paths)

    av.class_eval do
      include ApplicationHelper
    end

    Dir[File.join(Rails.root, "app", "controllers", "**","*.rb")].each {|f| load f}

    doc = Restapi.to_json()[:docs]

    # dir in public directory
    dir_path = File.join(::Rails.root.to_s, 'public', Restapi.configuration.doc_base_url)
    FileUtils.rm_r(dir_path) if File.directory?(dir_path)
    Dir.mkdir(dir_path)

    copy_jscss(File.join(dir_path, Restapi.configuration.doc_base_url))

    Restapi.configuration.doc_base_url = Restapi.configuration.doc_base_url[1..-1]
    File.open(File.join(dir_path,'index.html'), "w") do |f| 
      f.write av.render(
        :template => "restapi/restapis/static", 
        :locals => {:doc => doc}, 
        :layout => 'layouts/restapi/restapi')
      puts File.join(dir_path,'index.html')
    end

  end

  def copy_jscss(dest)
    src = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'app', 'public', 'restapi'))
    FileUtils.cp_r "#{src}/.", dest
  end
end
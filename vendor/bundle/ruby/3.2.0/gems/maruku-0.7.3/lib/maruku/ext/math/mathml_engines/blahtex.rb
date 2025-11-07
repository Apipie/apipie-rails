require 'fileutils'
require 'digest/md5'
require 'rexml/document'

module MaRuKu::Out::HTML
  PNG = Struct.new(:src, :depth, :height)

  def convert_to_png_blahtex(kind, tex)
    FileUtils.mkdir_p get_setting(:html_png_dir)

    # first, we check whether this image has already been processed
    md5sum = Digest::MD5.hexdigest(tex + " params: ")
    result_file = File.join(get_setting(:html_png_dir), md5sum + ".txt")

    if File.exists?(result_file)
      result = File.read(result_file)
    else
      args = [
              '--png',
              '--use-preview-package',
              '--shell-dvipng',
              "dvipng -D #{Shellwords.shellescape(get_setting(:html_png_resolution).to_s)}",
              "--temp-directory #{Shellwords.shellescape(get_setting(:html_png_dir))}",
              "--png-directory #{Shellwords.shellescape(get_setting(:html_png_dir))}"
             ]
      args << '--displaymath' if kind == :equation

      result = run_blahtex(tex, args)
    end

    if result.nil? || result.empty?
      maruku_error "Blahtex error: empty output"
      return
    end

    doc = REXML::Document.new(result)
    png = doc.root.elements.to_a.first
    if png.name != 'png'
      maruku_error "Blahtex error: \n#{doc}"
      return
    end

    raise "No depth element in:\n #{doc}" unless depth = png.xpath('//depth')[0]
    raise "No height element in:\n #{doc}" unless height = png.xpath('//height')[0]
    raise "No md5 element in:\n #{doc}" unless md5 = png.xpath('//md5')[0]

    depth = depth.text.to_f
    height = height.text.to_f
    raise "Height or depth was 0! in \n #{doc}" if height == 0 || depth == 0

    md5 = md5.text

    PNG.new("#{get_setting(:html_png_url)}#{md5}.png", depth, height)
  rescue => e
    maruku_error "Error: #{e}"
    nil
  end

  def convert_to_mathml_blahtex(kind, tex)
    result = run_blahtex(tex, %w[--mathml])

    doc = REXML::Document.new(result)
    mathml = doc.get_elements('//markup').to_a.first
    unless mathml
      maruku_error "Blahtex error: \n#{doc}"
      return nil
    end

    mathml.name = 'math'
    mathml.attributes['xmlns'] = "http://www.w3.org/1998/Math/MathML"
    mathml.attributes['display'] = (kind == :inline) ? :inline : :block

    MaRuKu::HTMLFragment.new(mathml.to_s)
  rescue => e
    maruku_error "Error: #{e}"
    nil
  end

  private

  # Run blahtex, return output
  def run_blahtex(tex, args)
    IO.popen(['blahtex', *args].join(' '), 'w+') do |blahtex|
      blahtex.write tex
      blahtex.close_write

      output = blahtex.read
      blahtex.close_read

      raise "Error running blahtex" unless $?.success?

      output
    end
  end
end

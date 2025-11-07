module MaRuKu
  # The Maruku version.
  VERSION = '0.7.3'

  # @deprecated Exists for backwards compatibility. Use {VERSION}
  # @private
  Version = VERSION

  # The URL of the Maruku website.
  MARUKU_URL = 'http://github.com/bhollis/maruku/'

  # @deprecated Exists for backwards compatibility. Use {MARUKU_URL}
  # @private
  MarukuURL = MARUKU_URL

  # Whether Markdown implements the PHP Markdown extra syntax.
  #
  # Note: it is not guaranteed that if this is false,
  # then no special features will be used.
  #
  # @return [Boolean]
  def markdown_extra?
    true
  end

  # Whether Markdown implements the new meta-data proposal.
  #
  # Note: it is not guaranteed that if this is false,
  # then no special features will be used.
  #
  # @return [Boolean]
  def new_meta_data?
    true
  end
end

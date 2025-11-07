# frozen_string_literal: true

##
module MIME
end

require "mime/types/deprecations"

# The definition of one MIME content-type.
#
# == Usage
#  require "mime/types"
#
#  plaintext = MIME::Types["text/plain"] # => [ text/plain ]
#  text = plaintext.first
#  puts text.media_type            # => "text"
#  puts text.sub_type              # => "plain"
#
#  puts text.extensions.join(" ")  # => "txt asc c cc h hh cpp hpp dat hlp"
#  puts text.preferred_extension   # => "txt"
#  puts text.friendly              # => "Text Document"
#  puts text.i18n_key              # => "text.plain"
#
#  puts text.encoding              # => quoted-printable
#  puts text.default_encoding      # => quoted-printable
#  puts text.binary?               # => false
#  puts text.ascii?                # => true
#  puts text.obsolete?             # => false
#  puts text.registered?           # => true
#  puts text.provisional?          # => false
#  puts text.complete?             # => true
#
#  puts text                       # => "text/plain"
#
#  puts text == "text/plain"       # => true
#  puts "text/plain" == text       # => true
#  puts text == "text/x-plain"     # => false
#  puts "text/x-plain" == text     # => false
#
#  puts MIME::Type.simplified("x-appl/x-zip") # => "x-appl/x-zip"
#  puts MIME::Type.i18n_key("x-appl/x-zip") # => "x-appl.x-zip"
#
#  puts text.like?("text/x-plain") # => true
#  puts text.like?(MIME::Type.new("content-type" => "x-text/x-plain")) # => true
#
#  puts text.xrefs.inspect # => { "rfc" => [ "rfc2046", "rfc3676", "rfc5147" ] }
#  puts text.xref_urls # => [ "http://www.iana.org/go/rfc2046",
#                      #      "http://www.iana.org/go/rfc3676",
#                      #      "http://www.iana.org/go/rfc5147" ]
#
#  xtext = MIME::Type.new("x-text/x-plain")
#  puts xtext.media_type # => "text"
#  puts xtext.raw_media_type # => "x-text"
#  puts xtext.sub_type # => "plain"
#  puts xtext.raw_sub_type # => "x-plain"
#  puts xtext.complete? # => false
#
#  puts MIME::Types.any? { |type| type.content_type == "text/plain" } # => true
#  puts MIME::Types.all?(&:registered?) # => false
#
#  # Various string representations of MIME types
#  qcelp = MIME::Types["audio/QCELP"].first # => audio/QCELP
#  puts qcelp.content_type         # => "audio/QCELP"
#  puts qcelp.simplified           # => "audio/qcelp"
#
#  xwingz = MIME::Types["application/x-Wingz"].first # => application/x-Wingz
#  puts xwingz.content_type        # => "application/x-Wingz"
#  puts xwingz.simplified          # => "application/x-wingz"
class MIME::Type
  # Reflects a MIME content-type specification that is not correctly
  # formatted (it is not +type+/+subtype+).
  class InvalidContentType < ArgumentError
    # :stopdoc:
    def initialize(type_string)
      @type_string = type_string
    end

    def to_s
      "Invalid Content-Type #{@type_string.inspect}"
    end
    # :startdoc:
  end

  # Reflects an unsupported MIME encoding.
  class InvalidEncoding < ArgumentError
    # :stopdoc:
    def initialize(encoding)
      @encoding = encoding
    end

    def to_s
      "Invalid Encoding #{@encoding.inspect}"
    end
    # :startdoc:
  end

  include Comparable

  # :stopdoc:
  # Full conformance with RFC 6838 §4.2 (the recommendation for < 64 characters is not
  # enforced or reported because MIME::Types mostly deals with registered data). RFC 4288
  # §4.2 does not restrict the first character to alphanumeric, but the total length of
  # each part is limited to 127 characters. RFCC 2045 §5.1 does not restrict the character
  # composition except for whitespace, but MIME::Type was always more strict than this.
  restricted_name_first = "[0-9a-zA-Z]"
  restricted_name_chars = "[-!#{$&}^_.+0-9a-zA-Z]{0,126}"
  restricted_name = "#{restricted_name_first}#{restricted_name_chars}"
  MEDIA_TYPE_RE = %r{(#{restricted_name})/(#{restricted_name})}.freeze
  I18N_RE = /[^[:alnum:]]/.freeze
  BINARY_ENCODINGS = %w[base64 8bit].freeze
  ASCII_ENCODINGS = %w[7bit quoted-printable].freeze
  # :startdoc:

  private_constant :MEDIA_TYPE_RE, :I18N_RE, :BINARY_ENCODINGS,
    :ASCII_ENCODINGS

  # Builds a MIME::Type object from the +content_type+, a MIME Content Type
  # value (e.g., "text/plain" or "application/x-eruby"). The constructed object
  # is yielded to an optional block for additional configuration, such as
  # associating extensions and encoding information.
  #
  # * When provided a Hash or a MIME::Type, the MIME::Type will be
  #   constructed with #init_with.
  #
  # There are two deprecated initialization forms:
  #
  # * When provided an Array, the MIME::Type will be constructed using
  #   the first element as the content type and the remaining flattened
  #   elements as extensions.
  # * Otherwise, the content_type will be used as a string.
  #
  # Yields the newly constructed +self+ object.
  def initialize(content_type) # :yields: self
    @friendly = {}
    @obsolete = @registered = @provisional = false
    @preferred_extension = @docs = @use_instead = @__sort_priority = nil

    self.extensions = []

    case content_type
    when Hash
      init_with(content_type)
    when Array
      MIME::Types.deprecated(
        class: MIME::Type,
        method: :new,
        pre: "when called with an Array",
        once: true
      )
      self.content_type = content_type.shift
      self.extensions = content_type.flatten
    when MIME::Type
      init_with(content_type.to_h)
    else
      MIME::Types.deprecated(
        class: MIME::Type,
        method: :new,
        pre: "when called with a String",
        once: true
      )
      self.content_type = content_type
    end

    self.encoding ||= :default
    self.xrefs ||= {}

    yield self if block_given?

    update_sort_priority
  end

  # Indicates that a MIME type is like another type. This differs from
  # <tt>==</tt> because <tt>x-</tt> prefixes are removed for this comparison.
  def like?(other)
    other =
      if other.respond_to?(:simplified)
        MIME::Type.simplified(other.simplified, remove_x_prefix: true)
      else
        MIME::Type.simplified(other.to_s, remove_x_prefix: true)
      end
    MIME::Type.simplified(simplified, remove_x_prefix: true) == other
  end

  # Compares the +other+ MIME::Type against the exact content type or the
  # simplified type (the simplified type will be used if comparing against
  # something that can be treated as a String with #to_s). In comparisons, this
  # is done against the lowercase version of the MIME::Type.
  #
  # Note that this implementation of #<=> is deprecated and will be changed
  # in the next major version to be the same as #priority_compare.
  #
  # Note that MIME::Types no longer compare against nil.
  def <=>(other)
    return priority_compare(other) if other.is_a?(MIME::Type)
    simplified <=> other
  end

  # Compares the +other+ MIME::Type using a pre-computed sort priority value,
  # then the simplified representation for an alphabetical sort.
  #
  # For the next major version of MIME::Types, this method will become #<=> and
  # #priority_compare will be removed.
  def priority_compare(other)
    if (cmp = __sort_priority <=> other.__sort_priority) == 0
      simplified <=> other.simplified
    else
      cmp
    end
  end

  # Uses a modified pre-computed sort priority value based on whether one of the provided
  # extensions is the preferred extension for a type.
  #
  # This is an internal function. If an extension provided is a preferred extension either
  # for this instance or the compared instance, the corresponding extension has its top
  # _extension_ bit cleared from its sort priority. That means that a type with between
  # 0 and 8 extensions will be treated as if it had 9 extensions.
  def __extension_priority_compare(other, exts) # :nodoc:
    tsp = __sort_priority

    if exts.include?(preferred_extension) && tsp & 0b1000 != 0
      tsp = tsp & 0b11110111 | 0b0111
    end

    osp = other.__sort_priority

    if exts.include?(other.preferred_extension) && osp & 0b1000 != 0
      osp = osp & 0b11110111 | 0b0111
    end

    if (cmp = tsp <=> osp) == 0
      simplified <=> other.simplified
    else
      cmp
    end
  end

  # Returns +true+ if the +other+ object is a MIME::Type and the content types
  # match.
  def eql?(other)
    other.is_a?(MIME::Type) && (self == other)
  end

  # Returns a hash based on the #simplified value.
  #
  # This maintains the invariant that two #eql? instances must have the same
  # #hash (although having the same #hash does *not* imply that the objects are
  # #eql?).
  #
  # To see why, suppose a MIME::Type instance +a+ is compared to another object
  # +b+, and that <code>a.eql?(b)</code> is true. By the definition of #eql?,
  # we know the following:
  #
  # 1. +b+ is a MIME::Type instance itself.
  # 2. <code>a == b</code> is true.
  #
  # Due to the first point, we know that +b+ should respond to the #simplified
  # method. Thus, per the definition of #<=>, we know that +a.simplified+ must
  # be equal to +b.simplified+, as compared by the <=> method corresponding to
  # +a.simplified+.
  #
  # Presumably, if <code>a.simplified <=> b.simplified</code> is +0+, then
  # +a.simplified+ has the same hash as +b.simplified+. So we assume it is
  # suitable for #hash to delegate to #simplified in service of the #eql?
  # invariant.
  def hash
    simplified.hash
  end

  # The computed sort priority value. This is _not_ intended to be used by most
  # callers.
  def __sort_priority # :nodoc:
    update_sort_priority if !instance_variable_defined?(:@__sort_priority) || @__sort_priority.nil?
    @__sort_priority
  end

  # Returns the whole MIME content-type string.
  #
  # The content type is a presentation value from the MIME type registry and
  # should not be used for comparison. The case of the content type is
  # preserved, and extension markers (<tt>x-</tt>) are kept.
  #
  #   text/plain        => text/plain
  #   x-chemical/x-pdb  => x-chemical/x-pdb
  #   audio/QCELP       => audio/QCELP
  attr_reader :content_type
  # A simplified form of the MIME content-type string, suitable for
  # case-insensitive comparison, with the content_type converted to lowercase.
  #
  #   text/plain        => text/plain
  #   x-chemical/x-pdb  => x-chemical/x-pdb
  #   audio/QCELP       => audio/qcelp
  attr_reader :simplified
  # Returns the media type of the simplified MIME::Type.
  #
  #   text/plain        => text
  #   x-chemical/x-pdb  => x-chemical
  #   audio/QCELP       => audio
  attr_reader :media_type
  # Returns the media type of the unmodified MIME::Type.
  #
  #   text/plain        => text
  #   x-chemical/x-pdb  => x-chemical
  #   audio/QCELP       => audio
  attr_reader :raw_media_type
  # Returns the sub-type of the simplified MIME::Type.
  #
  #   text/plain        => plain
  #   x-chemical/x-pdb  => pdb
  #   audio/QCELP       => QCELP
  attr_reader :sub_type
  # Returns the media type of the unmodified MIME::Type.
  #
  #   text/plain        => plain
  #   x-chemical/x-pdb  => x-pdb
  #   audio/QCELP       => qcelp
  attr_reader :raw_sub_type

  ##
  # The list of extensions which are known to be used for this MIME::Type.
  # Non-array values will be coerced into an array with #to_a. Array values
  # will be flattened, +nil+ values removed, and made unique.
  #
  # :attr_accessor: extensions
  def extensions
    @extensions.to_a
  end

  ##
  def extensions=(value) # :nodoc:
    clear_sort_priority
    @extensions = Set[*Array(value).flatten.compact].freeze
    MIME::Types.send(:reindex_extensions, self)
  end

  # Merge the +extensions+ provided into this MIME::Type. The extensions added
  # will be merged uniquely.
  def add_extensions(*extensions)
    self.extensions += extensions
  end

  ##
  # The preferred extension for this MIME type. If one is not set and there are
  # exceptions defined, the first extension will be used.
  #
  # When setting #preferred_extensions, if #extensions does not contain this
  # extension, this will be added to #extensions.
  #
  # :attr_accessor: preferred_extension

  ##
  def preferred_extension
    @preferred_extension || extensions.first
  end

  ##
  def preferred_extension=(value) # :nodoc:
    add_extensions(value) if value
    @preferred_extension = value
  end

  ##
  # The encoding (+7bit+, +8bit+, <tt>quoted-printable</tt>, or +base64+)
  # required to transport the data of this content type safely across a
  # network, which roughly corresponds to Content-Transfer-Encoding. A value of
  # +nil+ or <tt>:default</tt> will reset the #encoding to the
  # #default_encoding for the MIME::Type. Raises ArgumentError if the encoding
  # provided is invalid.
  #
  # If the encoding is not provided on construction, this will be either
  # "quoted-printable" (for text/* media types) and "base64" for eveything
  # else.
  #
  # :attr_accessor: encoding

  ##
  attr_reader :encoding

  ##
  def encoding=(enc) # :nodoc:
    if enc.nil? || (enc == :default)
      @encoding = default_encoding
    elsif BINARY_ENCODINGS.include?(enc) || ASCII_ENCODINGS.include?(enc)
      @encoding = enc
    else
      fail InvalidEncoding, enc
    end
  end

  # Returns the default encoding for the MIME::Type based on the media type.
  def default_encoding
    (@media_type == "text") ? "quoted-printable" : "base64"
  end

  ##
  # Returns the media type or types that should be used instead of this media
  # type, if it is obsolete. If there is no replacement media type, or it is
  # not obsolete, +nil+ will be returned.
  #
  # :attr_accessor: use_instead

  ##
  def use_instead
    obsolete? ? @use_instead : nil
  end

  ##
  attr_writer :use_instead

  # Returns +true+ if the media type is obsolete.
  #
  # :attr_accessor: obsolete
  attr_reader :obsolete
  alias_method :obsolete?, :obsolete

  ##
  def obsolete=(value)
    clear_sort_priority
    @obsolete = !!value
  end

  # The documentation for this MIME::Type.
  attr_accessor :docs

  # A friendly short description for this MIME::Type.
  #
  # call-seq:
  #   text_plain.friendly         # => "Text File"
  #   text_plain.friendly("en")   # => "Text File"
  def friendly(lang = "en")
    @friendly ||= {}

    case lang
    when String, Symbol
      @friendly[lang.to_s]
    when Array
      @friendly.update(Hash[*lang])
    when Hash
      @friendly.update(lang)
    else
      fail ArgumentError,
        "Expected a language or translation set, not #{lang.inspect}"
    end
  end

  # A key suitable for use as a lookup key for translations, such as with
  # the I18n library.
  #
  # call-seq:
  #    text_plain.i18n_key # => "text.plain"
  #    3gpp_xml.i18n_key   # => "application.vnd-3gpp-bsf-xml"
  #      # from application/vnd.3gpp.bsf+xml
  #    x_msword.i18n_key   # => "application.word"
  #      # from application/x-msword
  attr_reader :i18n_key

  ##
  # The cross-references list for this MIME::Type.
  #
  # :attr_accessor: xrefs

  ##
  attr_reader :xrefs

  ##
  def xrefs=(xrefs) # :nodoc:
    @xrefs = MIME::Types::Container.new(xrefs)
  end

  # The decoded cross-reference URL list for this MIME::Type.
  def xref_urls
    xrefs.flat_map { |type, values|
      name = :"xref_url_for_#{type.tr("-", "_")}"
      respond_to?(name, true) && xref_map(values, name) || values.to_a
    }
  end

  # Indicates whether the MIME type has been registered with IANA.
  #
  # :attr_accessor: registered
  attr_reader :registered
  alias_method :registered?, :registered

  ##
  def registered=(value)
    clear_sort_priority
    @registered = !!value
  end

  # Indicates whether the MIME type's registration with IANA is provisional.
  #
  # :attr_accessor: provisional
  attr_reader :provisional

  ##
  def provisional=(value)
    clear_sort_priority
    @provisional = !!value
  end

  # Indicates whether the MIME type's registration with IANA is provisional.
  def provisional?
    registered? && @provisional
  end

  # MIME types can be specified to be sent across a network in particular
  # formats. This method returns +true+ when the MIME::Type encoding is set
  # to <tt>base64</tt>.
  def binary?
    BINARY_ENCODINGS.include?(encoding)
  end

  # MIME types can be specified to be sent across a network in particular
  # formats. This method returns +false+ when the MIME::Type encoding is
  # set to <tt>base64</tt>.
  def ascii?
    ASCII_ENCODINGS.include?(encoding)
  end

  # Indicateswhether the MIME type is declared as a signature type.
  attr_accessor :signature
  alias_method :signature?, :signature

  # Returns +true+ if the MIME::Type specifies an extension list,
  # indicating that it is a complete MIME::Type.
  def complete?
    !@extensions.empty?
  end

  # Returns the MIME::Type as a string.
  def to_s
    content_type
  end

  # Returns the MIME::Type as a string for implicit conversions. This allows
  # MIME::Type objects to appear on either side of a comparison.
  #
  #   "text/plain" == MIME::Type.new("content-type" => "text/plain")
  def to_str
    content_type
  end

  # Converts the MIME::Type to a JSON string.
  def to_json(*args)
    require "json"
    to_h.to_json(*args)
  end

  # Converts the MIME::Type to a hash. The output of this method can also be
  # used to initialize a MIME::Type.
  def to_h
    encode_with({})
  end

  # Populates the +coder+ with attributes about this record for
  # serialization. The structure of +coder+ should match the structure used
  # with #init_with.
  #
  # This method should be considered a private implementation detail.
  def encode_with(coder)
    coder["content-type"] = @content_type
    coder["docs"] = @docs unless @docs.nil? || @docs.empty?
    coder["friendly"] = @friendly unless @friendly.nil? || @friendly.empty?
    coder["encoding"] = @encoding
    coder["extensions"] = @extensions.to_a unless @extensions.empty?
    coder["preferred-extension"] = @preferred_extension if @preferred_extension
    if obsolete?
      coder["obsolete"] = obsolete?
      coder["use-instead"] = use_instead if use_instead
    end
    unless xrefs.empty?
      {}.tap do |hash|
        xrefs.each do |k, v|
          hash[k] = v.to_a.sort
        end
        coder["xrefs"] = hash
      end
    end
    coder["registered"] = registered?
    coder["provisional"] = provisional? if provisional?
    coder["signature"] = signature? if signature?
    coder["sort-priority"] = __sort_priority || 0b11111111
    coder
  end

  # Initialize an empty object from +coder+, which must contain the
  # attributes necessary for initializing an empty object.
  #
  # This method should be considered a private implementation detail.
  def init_with(coder)
    @__sort_priority = 0
    self.content_type = coder["content-type"]
    self.docs = coder["docs"] || ""
    self.encoding = coder["encoding"]
    self.extensions = coder["extensions"] || []
    self.preferred_extension = coder["preferred-extension"]
    self.obsolete = coder["obsolete"] || false
    self.registered = coder["registered"] || false
    self.provisional = coder["provisional"] || false
    self.signature = coder["signature"]
    self.xrefs = coder["xrefs"] || {}
    self.use_instead = coder["use-instead"]

    friendly(coder["friendly"] || {})

    update_sort_priority
  end

  def inspect # :nodoc:
    # We are intentionally lying here because MIME::Type::Columnar is an
    # implementation detail.
    "#<MIME::Type: #{self}>"
  end

  class << self
    # MIME media types are case-insensitive, but are typically presented in a
    # case-preserving format in the type registry. This method converts
    # +content_type+ to lowercase.
    #
    # In previous versions of mime-types, this would also remove any extension
    # prefix (<tt>x-</tt>). This is no longer default behaviour, but may be
    # provided by providing a truth value to +remove_x_prefix+.
    def simplified(content_type, remove_x_prefix: false)
      simplify_matchdata(match(content_type), remove_x_prefix)
    end

    # Converts a provided +content_type+ into a translation key suitable for
    # use with the I18n library.
    def i18n_key(content_type)
      simplify_matchdata(match(content_type), joiner: ".") { |e|
        e.gsub!(I18N_RE, "-")
      }
    end

    # Return a +MatchData+ object of the +content_type+ against pattern of
    # media types.
    def match(content_type)
      case content_type
      when MatchData
        content_type
      else
        MEDIA_TYPE_RE.match(content_type)
      end
    end

    private

    def simplify_matchdata(matchdata, remove_x = false, joiner: "/")
      return nil unless matchdata

      matchdata.captures.map { |e|
        e.downcase!
        e.sub!(/^x-/, "") if remove_x
        yield e if block_given?
        e
      }.join(joiner)
    end
  end

  private

  def clear_sort_priority
    @__sort_priority = nil
  end

  # Update the __sort_priority value. Lower numbers sort better, so the
  # bitmapping may seem a little odd. The _best_ sort priority is 0.
  #
  # | bit | meaning         | details   |
  # | --- | --------------- | --------- |
  # | 7   | obsolete        | 1 if true |
  # | 6   | provisional     | 1 if true |
  # | 5   | registered      | 0 if true |
  # | 4   | complete        | 0 if true |
  # | 3   | # of extensions | see below |
  # | 2   | # of extensions | see below |
  # | 1   | # of extensions | see below |
  # | 0   | # of extensions | see below |
  #
  # The # of extensions is marked as the number of extensions subtracted from
  # 16, to a minimum of 0.
  def update_sort_priority
    extension_count = @extensions.length
    obsolete = (instance_variable_defined?(:@obsolete) && @obsolete) ? 1 << 7 : 0
    provisional = (instance_variable_defined?(:@provisional) && @provisional) ? 1 << 6 : 0
    registered = (instance_variable_defined?(:@registered) && @registered) ? 0 : 1 << 5
    complete = extension_count.nonzero? ? 0 : 1 << 4
    extension_count = [0, 16 - extension_count].max

    @__sort_priority = obsolete | registered | provisional | complete | extension_count
  end

  def content_type=(type_string)
    match = MEDIA_TYPE_RE.match(type_string)
    fail InvalidContentType, type_string if match.nil?

    @content_type = intern_string(type_string)
    @raw_media_type, @raw_sub_type = match.captures
    @simplified = intern_string(MIME::Type.simplified(match))
    @i18n_key = intern_string(MIME::Type.i18n_key(match))
    @media_type, @sub_type = MEDIA_TYPE_RE.match(@simplified).captures

    @raw_media_type = intern_string(@raw_media_type)
    @raw_sub_type = intern_string(@raw_sub_type)
    @media_type = intern_string(@media_type)
    @sub_type = intern_string(@sub_type)
  end

  if String.method_defined?(:-@)
    def intern_string(string)
      -string
    end
  else
    # MRI 2.2 and older do not have a method for string interning,
    # so we simply freeze them for keeping a similar interface
    def intern_string(string)
      string.freeze
    end
  end

  def xref_map(values, helper)
    values.map { |value| send(helper, value) }
  end

  def xref_url_for_rfc(value)
    "http://www.iana.org/go/%s" % value
  end

  def xref_url_for_draft(value)
    "http://www.iana.org/go/%s" % value.sub(/\ARFC/, "draft")
  end

  def xref_url_for_rfc_errata(value)
    "http://www.rfc-editor.org/errata_search.php?eid=%s" % value
  end

  def xref_url_for_person(value)
    "http://www.iana.org/assignments/media-types/media-types.xhtml#%s" % value
  end

  def xref_url_for_template(value)
    "http://www.iana.org/assignments/media-types/%s" % value
  end
end

require "mime/types/version"

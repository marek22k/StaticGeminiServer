
# Helper class for managing aliases
class AliasesManager

  def initialize settings
    @settings = settings['aliases']
  end

  # load and parse aliases
  def load_aliases
    @aliases = @settings
  end

  # returns an array of cert names
  def get_certsname_for_alias ali
    @aliases[ali]
  end

  # returns an array of arrays contains cert and key for a certname
  def get_certs_for_alias ali, crtmgr
    certsname = get_certsname_for_alias(ali)
    unless certsname
      raise CertificateNotFoundError, "Can not found a certificate for #{ali}"
    end

    crtmgr.get_certs certsname
  end

end

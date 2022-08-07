
class AliasesManager
  
  def initialize settings
    @settings = settings["aliases"]
  end
  
  # load and parse aliases
  def load_aliases
    @aliases = @settings
  end
  
  # returns an array of cert names
  def get_certsname_for_alias ali
    return @aliases[ali]
  end
  
  # returns an array of arrays contains cert and key for a certname
  def get_certs_for_alias ali, crtmgr
    certsname = get_certsname_for_alias(ali)
    if ! certsname
      raise CertificateNotFoundError.new "Can not found a certificate for #{ali}"
    end
    
    res = crtmgr.get_certs certsname
    
    return res
  end
  
end
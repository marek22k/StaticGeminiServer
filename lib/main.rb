
require_relative "GeminiServer"
require "yaml"

def check_settings settings
  res = settings["messages"]["not_found"]
  res = res and settings["messages"]["request_line_empty"]
  res = res and settings["messages"]["uri_too_long"]
  res = res and settings["messages"]["no_scheme"]
  res = res and settings["messages"]["wrong_scheme"]
  res = res and settings["messages"]["timeout"]
  res = res and settings["messages"]["path_injection_message"]
  res = res and settings["messages"]["domain_not_found"]
  res = res and settings["messages"]["wrong_port"]
  
  res = res and settings["server"]["host"]
  res = res and settings["server"]["port"]
  res = res and settings["server"]["client_timeout"]
  res = res and settings["server"]["default_mimetype"]
  res = res and settings["server"]["default_certificates"]
  
  res = res and settings["sites"]
  res = res and settings["aliases"]
  res = res and settings["certificates"]
  res = res and settings["files"]
  
  if ! res
    raise RuntimeError.new "Incomplete settings file!"
    exit!
  end
end

# Load settings
settings = YAML.load File.read "config.yml"

check_settings settings

# Create settings reader
crtmgr = CertManager.new settings
crtmgr.load_certs

alimgr = AliasesManager.new settings
alimgr.load_aliases

sitmgr = SitesManager.new settings
sitmgr.load_sites

filmgr = FileSettingsManager.new settings
filmgr.load_filesettings

# Create server
serv = GeminiServer.new crtmgr, alimgr, sitmgr, filmgr
serv.load_settings settings

# Start server
serv.start
serv.listen
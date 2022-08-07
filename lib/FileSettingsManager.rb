
class FileSettingsManager
  
  def initialize settings
    @settings = settings["files"]
  end
  
  def load_filesettings
    @exts = @settings
  end
  
  def get_mimetype ext
    return @exts[ext]
  end
  
end

# Helper class for managign settings for files
class FileSettingsManager

  def initialize settings
    @settings = settings['files']
  end

  def load_filesettings
    @exts = @settings
  end

  def get_mimetype ext
    @exts[ext]
  end

end

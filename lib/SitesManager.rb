
class SitesManager
  
  def initialize settings
    @settings = settings["sites"]
  end
  
  # load and parse sites
  def load_sites
    @roots = {}
    @indexes = {}
    @settings.each_pair { |id, site|
      site["aliases"].each { |ali|
        @roots[ali] = site["root_directory"]
        @indexes[ali] = site["index"]
      }
    }
  end
  
  # get root directory for a site
  def get_root_for_site ali
    return @roots[ali]
  end
  
  def exist? ali
    return @roots.has_key?(ali)
  end
  
  # get index file name for a site
  def get_index_for_site ali
    return @indexes[ali]
  end
  
end
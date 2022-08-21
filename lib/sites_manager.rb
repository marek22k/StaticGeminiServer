
# Helper class for managing sites
class SitesManager

  def initialize settings
    @settings = settings['sites']
  end

  # load and parse sites
  def load_sites
    @roots = {}
    @indexes = {}
    @settings.each_pair do |_id, site|
      site['aliases'].each do |ali|
        @roots[ali] = site['root_directory']
        @indexes[ali] = site['index']
      end
    end
  end

  # get root directory for a site
  def get_root_for_site ali
    @roots[ali]
  end

  def exist? ali
    @roots.key?(ali)
  end

  # get index file name for a site
  def get_index_for_site ali
    @indexes[ali]
  end

end

module Jekyll
  class GitHashGenerator < Generator
    priority :high
    def generate(site)
      site.config['commit_hash'] = `git rev-parse --short HEAD`.strip
    end
  end
end

> [!WARNING]
>
> This gem is experimental. It's currently running on a production application but
> use use with caution.

### Precompiled Gems

Running `bundle install` is slow, but not everything is the fault of Bundler. Compiling native extensions is the main bottleneck, this gem prevents the compilation of popular gems with native extensions resulting in a much faster `bundle install` for most projects.

> [!NOTE]
> ### Macbook Pro M4 results, running on Bundler 4.0.6 and Ruby 3.4.8.
>
> | Bundle install on a fresh Rails application | Without this plugin | With this plugin        |
> |---------------------------------------------|---------------------|-------------------------|
> | 1st run                                     | 11.216s             |  3.501s (3.20x faster)  |
> | 2nd run                                     | 12.654s             |  3.388s (3.73x faster)  |
> | 3rd run                                     | 10.594s             |  3.359s (3.20x faster)  |

### Installation

At the very beginning of your Gemfile, add this snippet:

```ruby
source "https://rubygems.org"

#### Add this snippet in your Gemfile
plugin "precompiled_gems"

if Bundler::Plugin.installed?('precompiled_gems')
  Plugin.send(:load_plugin, 'precompiled_gems')

  precompiled_gems!
end
####
```

### Usage

Once you have added the above snippet in your Gemfile, you can run `bundle install` and compilation of popular gems with native extensions will no longer be required.

### How it works

The plugin hijacks Bundler resolution and download a set of different gems with precompiled binaries. Those gems are forks of the original gem.

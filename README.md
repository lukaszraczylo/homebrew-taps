# Homebrew Tap

Custom Homebrew tap for macOS and Linux tools by Lukasz Raczylo.

## Available Casks

| Cask | Description |
|------|-------------|
| [kportal](https://github.com/lukaszraczylo/kportal) | Modern Kubernetes port-forward manager with interactive TUI |
| [lolcathost](https://github.com/lukaszraczylo/lolcathost) | Dynamic hosts file manager with interactive terminal UI |
| [semver-generator](https://github.com/lukaszraczylo/semver-generator) | Automatic semantic version generator based on git commit messages |

## Installation

### Add the tap

```bash
brew tap lukaszraczylo/taps
```

### Install a cask

```bash
brew install --cask lukaszraczylo/taps/<cask-name>
```

Or install directly:

```bash
brew install --cask lukaszraczylo/taps/kportal
```

### Using Brewfile

Add to your Brewfile:

```ruby
tap "lukaszraczylo/taps"
cask "kportal"
cask "lolcathost"
cask "semver-generator"
```

## Documentation

- [Full Documentation](https://lukaszraczylo.github.io/homebrew-taps/)
- [Homebrew Documentation](https://docs.brew.sh)

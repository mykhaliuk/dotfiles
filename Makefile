.PHONY: install brew mise apply

UNAME := $(shell uname)
BREW_PREFIX := /opt/homebrew
export PATH := $(BREW_PREFIX)/bin:$(PATH)
PORTABLE_RUBY := $(BREW_PREFIX)/Library/Homebrew/vendor/portable-ruby/current/bin

install: mise
	$(MAKE) apply

brew:
ifeq ($(UNAME),Darwin)
	@command -v brew >/dev/null 2>&1 || \
	  /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
endif

mise: brew
ifeq ($(UNAME),Darwin)
	brew install mise
else
	sudo dnf copr enable -y jdxcode/mise && sudo dnf install -y mise git
endif

apply:
	mkdir -p ~/.config
	@if [ -L ~/.config/mise ] && [ "$$(readlink ~/.config/mise)" = "$$HOME/dotfiles/home/.config/mise" ]; then \
	  echo "~/.config/mise is already linked"; \
	elif [ -e ~/.config/mise ] || [ -L ~/.config/mise ]; then \
	  echo "~/.config/mise exists and is not the link to ~/dotfiles/home/.config/mise: move it away and run make apply again" >&2; exit 1; \
	else \
	  [ -d ~/dotfiles/home/.config/mise ] || { echo "clone this repository to ~/dotfiles"; exit 1; }; \
	  ln -s ~/dotfiles/home/.config/mise ~/.config/mise; \
	fi
ifeq ($(UNAME),Darwin)
	@[ -d "$(PORTABLE_RUBY)" ] || { echo "Homebrew portable Ruby is missing at $(PORTABLE_RUBY): run brew update, then make apply again" >&2; exit 1; }
	PATH="$(PORTABLE_RUBY):$$PATH" mise bootstrap --yes
else
	mise bootstrap --yes
endif

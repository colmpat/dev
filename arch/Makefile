MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
WP_DIR := $(dir $(MKFILE_PATH))wallpapers
DELUGE_DIR := $(dir $(MKFILE_PATH))deluge

include ../Makefile

all: install update-boot-conf nvim ensure-oh-my-zsh link sync-wallpapers enable-gamemoded configure-nordvpn configure-deluge

PACMAN_PACKAGES := tmux go steam lua51 luarocks base-devel cmake unzip ninja curl rofi-wayland waybar btop hyprpaper \
						wireplumber gamemode deluge nodejs npm

YAY_PACKAGES := libation spotify nordvpn-bin 

.PHONY: install
install: $(PACMAN_PACKAGES) $(YAY_PACKAGES)

.PHONY: sync-mirrors
sync-mirrors:
	@sudo reflector --country US --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
	@sudo pacman -Syyu

.PHONY: rebuild-yay
rebuild-yay:
	@cd ~ && \
	sudo pacman -Rns yay-bin-debug || true && \
	rm -rf yay && \
	git clone https://aur.archlinux.org/yay.git && \
	cd yay && \
	makepkg -si

$(PACMAN_PACKAGES) &:
	@echo "Ensuring $(PACMAN_PACKAGES) is installed..."
	@pacman -Q $(PACMAN_PACKAGES) > /dev/null 2>&1 || { \
		echo "Installing $(PACMAN_PACKAGES)..."; \
		sudo pacman -S --noconfirm $(PACMAN_PACKAGES); \
	}

$(YAY_PACKAGES) &:
	@echo "Ensuring $(YAY_PACKAGES) is installed..."
	@yay -Q $(YAY_PACKAGES) > /dev/null 2>&1 || { \
		echo "Installing $(YAY_PACKAGES)..."; \
		yay -S --noconfirm $(YAY_PACKAGES); \
	}

update-boot-conf:
	@echo "TODO: CHANGE THE timeout in /boot/loader/loader.conf TO ZERO!"
	@echo "TODO: COMMENT OUT nvidia-uvm IN /usr/lib/modules-load.d"

enable-multilib:
	@echo "TODO: YOU MUST UN-COMMENT the multilib inclusion in /etc/pacman.conf"

sync-wallpapers:
	@sudo mkdir -p /wallpapers && sudo cp $(WP_DIR)/* /wallpapers

enable-gamemoded:
	@sudo systemctl daemon-reload; sudo systemctl --user enable --now gamemoded

.PHONY: configure-nordvpn
configure-nordvpn:
	@sudo groupadd nordvpn || true
	@sudo usermod -aG nordvpn $$USER || true
	@nordvpn login || true
	@nordvpn set autoconnect on
	@nordvpn set technology nordlynx
	@nordvpn set killswitch off

.PHONY: configure-deluge
configure-deluge: install-nftables install-deluge-systemd install-deluge-config
	@sudo usermod -aG deluge $$USER
	@sudo mkdir -p /drives/ssd/500gb/deluge
	@sudo chown deluge:deluge /drives/ssd/500gb/deluge /drives/hdd/4tb/tor /drives/hdd/4tb/data
	@sudo chmod 2775 /drives/ssd/500gb/deluge /drives/hdd/4tb/tor /drives/hdd/4tb/data
	@sudo systemctl daemon-reload
	@sudo systemctl enable --now deluged.service deluge-web.service

.PHONY: install-deluge-systemd
install-deluge-systemd:
	@sudo install -m 644 $(DELUGE_DIR)/deluged.service /etc/systemd/system/deluged.service
	@sudo install -m 644 $(DELUGE_DIR)/deluge-web.service /etc/systemd/system/deluge-web.service
	@sudo install -m 755 $(DELUGE_DIR)/configure-interfaces.sh /etc/deluge-configure-interfaces.sh

.PHONY: install-deluge-config
install-deluge-config:
	@sudo systemctl stop deluged.service deluge-web.service || true
	@sudo install -m 600 -o deluge -g deluge $(DELUGE_DIR)/core.conf /srv/deluge/.config/deluge/core.conf
	@sudo rm -f /srv/deluge/.config/deluge/session.state /srv/deluge/.config/deluge/session.state.bak
	@sudo systemctl start deluged.service deluge-web.service

.PHONY: install-nftables
install-nftables:
	@sudo install -m 644 $(DELUGE_DIR)/nftables.conf /etc/deluge-killswitch.nft

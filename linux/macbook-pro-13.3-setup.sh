#!/usr/bin/env bash
set -Eeuo pipefail

readonly MODEL='MacBookPro13,3'
readonly NVRAM_URL='https://raw.githubusercontent.com/DeyAgrO/macbook-pro-13-2-linux/1d52273baa4d86f71113b4e65a181c839fce94fb/firmware/brcmfmac43602-pcie.txt'
readonly NVRAM_SHA256='997b2d95b5ee822da57f704f77e985ff995b151c3705b32ee4656e25c1f6c47e'
readonly NVRAM_TARGET='/usr/lib/firmware/brcm/brcmfmac43602-pcie.txt'
readonly SOUND_REPO='https://github.com/davidjo/snd_hda_macbookpro.git'
readonly SOUND_REV='89b22ff90b86468b186706861dd18663562defa7'
readonly SOUND_DIR="$HOME/src/snd_hda_macbookpro"
readonly HERDR_UNIT="$HOME/.config/systemd/user/herdr.service"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly script_dir

check_only=false
wifi_router=''
todo_count=0
reboot_needed=false
current_step='start'

trap 'printf "fail  %s\n" "$current_step" >&2' ERR

usage() {
  echo "usage: $0 [--check] [--wifi-router <connection>]"
}

ok() {
  printf 'ok    %s\n' "$1"
}

# Returns 0 when the caller must run the fix.
needs_fix() {
  if "$check_only"; then
    printf 'todo  %s\n' "$1"
    todo_count=$((todo_count + 1))
    return 1
  fi
  printf 'fix   %s\n' "$1"
}

file_matches() {
  [ "$(cat "$1" 2>/dev/null || true)" = "$2" ]
}

write_root_file() {
  sudo install -d "$(dirname "$1")"
  printf '%s\n' "$2" | sudo tee "$1" >/dev/null
}

check_kernel() {
  current_step='kernel'
  local version package
  local -a missing=() incomplete=()
  while read -r version; do
    local complete=true
    for package in kernel kernel-core kernel-modules-core kernel-modules kernel-modules-extra; do
      if ! rpm -q "$package-$version" >/dev/null 2>&1; then
        missing+=("$package-$version")
        complete=false
      fi
    done
    if ! "$complete"; then
      incomplete+=("$version")
    fi
  done < <(rpm -q kernel-core --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n')

  if [ "${#missing[@]}" -eq 0 ]; then
    ok 'kernel: every installed version has all its packages'
  elif needs_fix "kernel: missing ${missing[*]}"; then
    sudo dnf install -y "${missing[@]}"
    for version in "${incomplete[@]}"; do
      sudo dracut -f --kver "$version"
    done
    reboot_needed=true
  fi
}

check_gpu() {
  current_step='gpu'
  # Without amdgpu.dpm=0, about half of the boots end in a hardware reset at session start.
  if grep -qF 'amdgpu.dpm=0' /proc/cmdline; then
    ok 'gpu: amdgpu.dpm=0 is active'
  elif needs_fix 'gpu: amdgpu.dpm=0 is not active'; then
    sudo grubby --update-kernel=ALL --args='amdgpu.dpm=0'
    reboot_needed=true
  fi
}

check_sleep() {
  current_step='sleep'
  local -a targets=(sleep.target suspend.target hibernate.target hybrid-sleep.target)
  local lid_conf='/etc/systemd/logind.conf.d/lid.conf'
  local lid_content
  lid_content=$'[Login]\nHandleLidSwitch=ignore\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitchDocked=ignore'
  local target masked=true
  for target in "${targets[@]}"; do
    if [ "$(systemctl is-enabled "$target" 2>/dev/null || true)" != 'masked' ]; then
      masked=false
    fi
  done

  if "$masked" && file_matches "$lid_conf" "$lid_content"; then
    ok 'sleep: targets are masked and the lid switch is ignored'
  elif needs_fix 'sleep: targets are not masked or the lid switch is not ignored'; then
    sudo systemctl mask "${targets[@]}"
    write_root_file "$lid_conf" "$lid_content"
    reboot_needed=true
  fi
}

find_wifi_interface() {
  local path
  for path in /sys/class/net/*/wireless; do
    if [ -d "$path" ]; then
      basename "$(dirname "$path")"
      return
    fi
  done
}

# Do not add a generic clm_blob: it halts the chip on Apple boards.
install_nvram() {
  local mac=$1 download
  download="$(mktemp)"
  curl -fsSL "$NVRAM_URL" -o "$download"
  printf '%s  %s\n' "$NVRAM_SHA256" "$download" | sha256sum -c --quiet -
  sed "s/^macaddr=.*/macaddr=$mac/" "$download" | sudo tee "$NVRAM_TARGET" >/dev/null
  rm -f "$download"
}

check_wifi_files() {
  local mac=$1 changed=false path content
  if grep -qsx "macaddr=$mac" "$NVRAM_TARGET"; then
    ok 'wifi: NVRAM is in place'
  elif needs_fix 'wifi: NVRAM is missing or has another MAC'; then
    install_nvram "$mac"
    changed=true
  fi

  while IFS='|' read -r path content; do
    content="$(printf '%b' "$content")"
    if file_matches "$path" "$content"; then
      ok "wifi: $path"
    elif needs_fix "wifi: $path"; then
      write_root_file "$path" "$content"
      changed=true
    fi
  done <<'FILES'
/etc/modprobe.d/brcmfmac.conf|options brcmfmac feature_disable=0x82000 roamoff=1
/etc/modprobe.d/cfg80211.conf|options cfg80211 ieee80211_regdom=FR
/etc/NetworkManager/conf.d/wifi-powersave.conf|[connection]\nwifi.powersave = 2
FILES

  # No module reload: Wi-Fi is the only network here, so a reload cuts an SSH session.
  if "$changed"; then
    sudo dracut -f
    reboot_needed=true
  fi
}

check_wifi_connection() {
  if [ -z "$wifi_router" ]; then
    return
  fi
  local pmf band
  pmf="$(nmcli -g 802-11-wireless-security.pmf connection show "$wifi_router")"
  band="$(nmcli -g 802-11-wireless.band connection show "$wifi_router")"
  case "$pmf" in
    1 | *disable*) ok "wifi: PMF is off on $wifi_router" ;;
    *)
      if needs_fix "wifi: PMF is on for $wifi_router"; then
        sudo nmcli connection modify "$wifi_router" 802-11-wireless-security.pmf disable
      fi
      ;;
  esac
  if [ "$band" = 'a' ]; then
    ok "wifi: $wifi_router stays on 5 GHz"
  elif needs_fix "wifi: $wifi_router is not limited to 5 GHz"; then
    sudo nmcli connection modify "$wifi_router" 802-11-wireless.band a
  fi
}

check_wifi_band() {
  if ! command -v iw >/dev/null 2>&1; then
    printf 'todo  wifi: install iw, then run this check again\n'
    todo_count=$((todo_count + 1))
  elif iw list | grep -q 'Band 2'; then
    ok 'wifi: the 5 GHz band is available'
  elif "$reboot_needed"; then
    printf 'todo  wifi: look for the 5 GHz band after the reboot\n'
  else
    printf 'todo  wifi: the 5 GHz band is not available\n'
    todo_count=$((todo_count + 1))
  fi
}

check_wifi() {
  current_step='wifi'
  local interface
  interface="$(find_wifi_interface)"
  if [ -z "$interface" ]; then
    printf 'todo  wifi: no Wi-Fi interface, fix the kernel packages and reboot\n'
    todo_count=$((todo_count + 1))
    return
  fi
  check_wifi_files "$(cat "/sys/class/net/$interface/address")"
  check_wifi_connection
  check_wifi_band
}

install_sound_driver() {
  local kernel=$1
  # Not kernel-devel-matched: it pulls the newest kernel-core without its modules.
  sudo dnf install -y "kernel-devel-$kernel" dkms gcc make patch wget2-wget
  if [ ! -d "$SOUND_DIR" ]; then
    git clone "$SOUND_REPO" "$SOUND_DIR"
  fi
  git -C "$SOUND_DIR" fetch origin
  git -C "$SOUND_DIR" checkout --detach "$SOUND_REV"
  (cd "$SOUND_DIR" && sudo ./install.cirrus.driver.sh -i)
}

check_sound() {
  current_step='sound'
  local kernel module
  kernel="$(uname -r)"
  module="$(find "/lib/modules/$kernel/updates" -name 'snd-hda-codec-cs8409.ko*' 2>/dev/null || true)"
  if [ -n "$module" ]; then
    ok "sound: the CS8409 driver is built for $kernel"
  elif needs_fix "sound: no CS8409 driver for $kernel"; then
    install_sound_driver "$kernel"
    reboot_needed=true
  fi
}

check_keyd() {
  current_step='keyd'
  local source="$script_dir/etc/keyd/default.conf"
  local target='/etc/keyd/default.conf'
  if ! command -v keyd >/dev/null 2>&1; then
    printf 'todo  keyd: run mise bootstrap packages apply, then run this check again\n'
    todo_count=$((todo_count + 1))
  elif cmp -s "$source" "$target" && systemctl is-active --quiet keyd && systemctl is-enabled --quiet keyd; then
    ok 'keyd: the config is in place and the service runs'
  elif needs_fix 'keyd: the config differs or the service does not run'; then
    sudo install -D -m 644 "$source" "$target"
    sudo systemctl enable --now keyd
    sudo keyd reload
  fi
}

check_herdr() {
  current_step='herdr'
  local user content
  user="$(id -un)"
  content=$'[Unit]\nDescription=Herdr server\nAfter=network-online.target\n\n[Service]\nEnvironment=PATH=%h/.local/bin:%h/.local/share/mise/shims:/usr/local/bin:/usr/bin\nExecStart=/usr/bin/env herdr server\nRestart=on-failure\nRestartSec=5\n\n[Install]\nWantedBy=default.target'
  if file_matches "$HERDR_UNIT" "$content" \
    && systemctl --user is-enabled --quiet herdr.service \
    && [ "$(loginctl show-user "$user" -p Linger --value 2>/dev/null || true)" = 'yes' ]; then
    ok 'herdr: the user unit is enabled and linger is on'
  elif needs_fix 'herdr: the unit differs, is not enabled, or linger is off'; then
    mkdir -p "$(dirname "$HERDR_UNIT")"
    printf '%s\n' "$content" >"$HERDR_UNIT"
    systemctl --user daemon-reload
    systemctl --user enable herdr.service
    sudo loginctl enable-linger "$user"
  fi
}

main() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --check) check_only=true ;;
      --wifi-router)
        wifi_router="${2:?--wifi-router needs a connection name}"
        shift
        ;;
      *)
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  if [ "$(uname -s)" != 'Linux' ] || [ "$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)" != "$MODEL" ]; then
    echo "This machine is not a $MODEL: nothing to do."
    exit 0
  fi

  if ! "$check_only"; then
    sudo -v
  fi

  check_kernel
  check_gpu
  check_sleep
  check_wifi
  check_sound
  check_keyd
  check_herdr

  if "$reboot_needed"; then
    echo 'Reboot now: the kernel, GPU, sleep, Wi-Fi or sound settings changed.'
  fi
  [ "$todo_count" -eq 0 ]
}

main "$@"

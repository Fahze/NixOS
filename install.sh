#!/usr/bin/env bash
#
# Installer for the "thinkpad-fahze" host, to be run from the NixOS live USB.
#
#   sudo ./install.sh [--dry-run] [--disk /dev/nvme0n1] [--esp 1G] [--root 580G|max]
#
# It follows docs/INSTALL.md: GPT partitioning (ESP + LUKS2 root), btrfs
# subvolumes, sops machine key, hardware-configuration.nix, nixos-install and
# a copy of this repository to ~/NixOS. Everything that changes the system goes
# through run()/run_sh(), so --dry-run only prints what would be executed.
#
# Prerequisites (see docs/INSTALL.md, sections A and C):
#   - secrets/secrets.yaml exists (password secret created from WSL);
#   - network access (the repository was cloned from the live USB);
#   - Secure Boot disabled, UEFI mode.

set -euo pipefail

HOST="thinkpad-fahze"
DRY_RUN=false
DISK=""
ESP_SIZE="1G"
ROOT_SIZE="580G" # "max" = the whole remaining space
MAPPER_NAME="cryptroot"
MNT="/mnt"
BTRFS_OPTS="compress=zstd,noatime"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "\n${GREEN}$*${NC}"; }
warn() { echo -e "${YELLOW}$*${NC}"; }
error() { echo -e "${RED}Error: $*${NC}" >&2; }
die() {
  error "$*"
  exit 1
}

usage() {
  cat <<EOF
Usage: sudo ./install.sh [options]

  --dry-run        print every command that would change the system, run nothing
  --disk DEVICE    target disk (default: choose from a list)
  --esp SIZE       EFI system partition size, e.g. 1G or 512M (default: $ESP_SIZE)
  --root SIZE      LUKS root partition size, e.g. 580G, or "max" (default: $ROOT_SIZE)
  --host NAME      host to install (default: $HOST)
  -h, --help       show this help

The space left after the root partition stays unallocated (room for a future Windows).
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
  --dry-run) DRY_RUN=true ;;
  --disk)
    DISK="${2:?--disk needs a device}"
    shift
    ;;
  --esp)
    ESP_SIZE="${2:?--esp needs a size}"
    shift
    ;;
  --root)
    ROOT_SIZE="${2:?--root needs a size}"
    shift
    ;;
  --host)
    HOST="${2:?--host needs a name}"
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    usage
    die "unknown option: $1"
    ;;
  esac
  shift
done

# Run a command, or only print it with --dry-run.
run() {
  echo -en "${BLUE}+ "
  printf '%q ' "$@"
  echo -e "${NC}"
  if ! $DRY_RUN; then "$@"; fi
}

# Same, for a shell snippet (redirections, pipes).
run_sh() {
  echo -e "${BLUE}+ $1${NC}"
  if ! $DRY_RUN; then bash -c "$1"; fi
}

# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

check_environment() {
  local problems=0

  # Fail hard on a real run, only warn with --dry-run (so the script can be tried anywhere).
  fail() {
    if $DRY_RUN; then
      warn "[dry-run] $*"
    else
      error "$*"
      problems=1
    fi
  }

  if [ ! -d /iso ] && [ "$(findmnt -no FSTYPE / 2>/dev/null)" != "tmpfs" ]; then
    fail "this script must be run from the NixOS live USB (it would erase a disk)."
  fi
  [ "$(id -u)" = "0" ] || fail "run it as root: sudo ./install.sh"
  [ -d /sys/firmware/efi ] || fail "the machine is not booted in UEFI mode (check the BIOS settings)."
  [ -f "$REPO/flake.nix" ] || fail "flake.nix not found next to install.sh."
  [ -d "$REPO/hosts/$HOST" ] || fail "unknown host '$HOST' (no hosts/$HOST directory)."
  [ -f "$REPO/secrets/secrets.yaml" ] || fail "secrets/secrets.yaml is missing: create the password secret first (docs/INSTALL.md, A3)."

  local tool
  for tool in curl lsblk sgdisk cryptsetup mkfs.btrfs mkfs.fat btrfs git ssh-keygen nixos-generate-config nixos-install nix; do
    command -v "$tool" >/dev/null 2>&1 || fail "missing command: $tool"
  done

  if ! curl -fsSI --max-time 8 https://github.com >/dev/null 2>&1; then
    fail "no network access. Connect first (nmcli device wifi connect <SSID> --ask)."
  fi

  [ "$problems" = 0 ] || exit 1
}

# ---------------------------------------------------------------------------
# Disk selection and layout
# ---------------------------------------------------------------------------

size_to_mib() {
  case "$1" in
  *G) echo $((${1%G} * 1024)) ;;
  *M) echo "${1%M}" ;;
  esac
}

disk_bytes() {
  if [ -b "$1" ]; then blockdev --getsize64 "$1"; else stat -c %s "$1"; fi
}

part_path() { # part_path <number>
  case "$DISK" in
  *[0-9]) echo "${DISK}p$1" ;;
  *) echo "${DISK}$1" ;;
  esac
}

select_disk() {
  if [ -n "$DISK" ]; then
    [ -e "$DISK" ] || die "$DISK does not exist."
    return
  fi

  # Do not offer the disk holding the live USB.
  local iso_src iso_disk=""
  iso_src="$(findmnt -no SOURCE /iso 2>/dev/null || true)"
  if [ -n "$iso_src" ]; then
    iso_disk="/dev/$(lsblk -no PKNAME "$iso_src" 2>/dev/null | head -n1)"
  fi

  local candidates=() d
  while read -r d; do
    [ "$d" = "$iso_disk" ] && continue
    candidates+=("$d")
  done < <(lsblk -dpno NAME,TYPE | awk '$2 == "disk" { print $1 }')

  [ "${#candidates[@]}" -gt 0 ] || die "no disk found."

  info "Available disks:"
  local i=1
  for d in "${candidates[@]}"; do
    printf '  %d) %s  %s\n' "$i" "$d" "$(lsblk -dno SIZE,TRAN,MODEL "$d" | tr -s ' ')"
    i=$((i + 1))
  done

  local choice
  while true; do
    read -rp "Select the target disk [1-${#candidates[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#candidates[@]}" ]; then
      DISK="${candidates[$((choice - 1))]}"
      break
    fi
    error "invalid choice."
  done
}

validate_sizes() {
  [[ "$ESP_SIZE" =~ ^[0-9]+[GM]$ ]] || die "invalid ESP size '$ESP_SIZE' (use e.g. 1G or 512M)."
  if [ "$ROOT_SIZE" != "max" ]; then
    [[ "$ROOT_SIZE" =~ ^[0-9]+[GM]$ ]] || die "invalid root size '$ROOT_SIZE' (use e.g. 580G, or max)."
  fi

  local disk_mib esp_mib root_mib
  disk_mib=$(($(disk_bytes "$DISK") / 1024 / 1024))
  esp_mib=$(size_to_mib "$ESP_SIZE")
  [ "$esp_mib" -ge 256 ] || die "the ESP must be at least 256M."

  if [ "$ROOT_SIZE" = "max" ]; then
    root_mib=$((disk_mib - esp_mib - 2))
  else
    root_mib=$(size_to_mib "$ROOT_SIZE")
  fi
  [ "$root_mib" -ge 20480 ] || die "the root partition must be at least 20G."
  [ $((esp_mib + root_mib + 2)) -le "$disk_mib" ] ||
    die "ESP ($ESP_SIZE) + root ($ROOT_SIZE) do not fit on $DISK ($((disk_mib / 1024)) GiB)."

  FREE_MIB=$((disk_mib - esp_mib - root_mib - 2))
  DISK_MIB=$disk_mib
}

ask_layout() {
  info "Partition sizes (Enter to keep the default; the rest of the disk stays unallocated)"
  local answer
  read -rp "ESP size [$ESP_SIZE]: " answer
  ESP_SIZE="${answer:-$ESP_SIZE}"
  read -rp "Root (LUKS2 + btrfs) size, or 'max' [$ROOT_SIZE]: " answer
  ROOT_SIZE="${answer:-$ROOT_SIZE}"
}

confirm_plan() {
  info "Summary"
  echo "  Host:            $HOST"
  echo "  User:            $USERNAME"
  echo "  Disk:            $DISK ($((DISK_MIB / 1024)) GiB)"
  echo "  1) ESP           $ESP_SIZE, FAT32, mounted on /boot"
  echo "  2) cryptroot     $ROOT_SIZE, LUKS2 -> btrfs (@, @home, @nix; $BTRFS_OPTS)"
  echo "  Left unallocated ~$((FREE_MIB / 1024)) GiB"
  echo
  lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS "$DISK" || true
  echo
  warn "ALL DATA ON $DISK WILL BE ERASED."

  if $DRY_RUN; then
    warn "[dry-run] nothing will be executed."
    return
  fi
  local answer
  read -rp "Type the disk name ($DISK) to confirm: " answer
  [ "$answer" = "$DISK" ] || die "confirmation does not match, aborting."
}

partition_and_format() {
  local esp_part root_part root_end
  esp_part="$(part_path 1)"
  root_part="$(part_path 2)"
  if [ "$ROOT_SIZE" = "max" ]; then root_end="0"; else root_end="+$ROOT_SIZE"; fi

  info "Cleaning previous mounts"
  if findmnt -R "$MNT" >/dev/null 2>&1; then run umount -R "$MNT"; fi
  if [ -e "/dev/mapper/$MAPPER_NAME" ]; then run cryptsetup close "$MAPPER_NAME"; fi

  info "Partitioning $DISK"
  run wipefs --all --force "$DISK"
  run sgdisk --zap-all "$DISK"
  run sgdisk -n "1:0:+$ESP_SIZE" -t 1:ef00 -c 1:ESP "$DISK"
  run sgdisk -n "2:0:$root_end" -t 2:8309 -c 2:cryptroot "$DISK"
  run partprobe "$DISK"
  run udevadm settle

  info "LUKS2 on $root_part (choose a strong passphrase; type YES in capitals when asked)"
  run cryptsetup luksFormat --type luks2 "$root_part"
  run cryptsetup open "$root_part" "$MAPPER_NAME"

  info "Filesystems"
  run mkfs.fat -F 32 -n ESP "$esp_part"
  run mkfs.btrfs -f -L nixos "/dev/mapper/$MAPPER_NAME"

  run mount "/dev/mapper/$MAPPER_NAME" "$MNT"
  local sv
  for sv in @ @home @nix; do
    run btrfs subvolume create "$MNT/$sv"
  done
  run umount "$MNT"

  info "Mounting under $MNT"
  run mount -o "subvol=@,$BTRFS_OPTS" "/dev/mapper/$MAPPER_NAME" "$MNT"
  run mkdir -p "$MNT/home" "$MNT/nix" "$MNT/boot"
  run mount -o "subvol=@home,$BTRFS_OPTS" "/dev/mapper/$MAPPER_NAME" "$MNT/home"
  run mount -o "subvol=@nix,$BTRFS_OPTS" "/dev/mapper/$MAPPER_NAME" "$MNT/nix"
  run mount "$esp_part" "$MNT/boot"
  if ! $DRY_RUN; then lsblk -f "$DISK"; fi
}

# ---------------------------------------------------------------------------
# sops machine key
# ---------------------------------------------------------------------------

sops_ready() { # the machine key must be in .sops.yaml AND in the encrypted file
  grep -qF "$AGE_KEY" "$REPO/.sops.yaml" && grep -qF "$AGE_KEY" "$REPO/secrets/secrets.yaml"
}

git_pull() {
  if git -C "$REPO" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    git -C "$REPO" pull --ff-only
  else
    warn "No upstream branch configured: pull the changes by hand (git pull) and press Enter."
    read -rp "" _
  fi
}

setup_machine_key() {
  local key="$MNT/etc/ssh/ssh_host_ed25519_key"

  info "Machine key for sops-nix"
  run mkdir -p "$MNT/etc/ssh"
  if [ -e "$key" ] && ! $DRY_RUN; then
    warn "$key already exists, it is kept."
  else
    run ssh-keygen -q -t ed25519 -N "" -f "$key"
  fi
  run chmod 600 "$key"

  if $DRY_RUN; then
    AGE_KEY="age1-dry-run-placeholder"
    warn "[dry-run] the age key would be derived with ssh-to-age and checked in .sops.yaml."
    return
  fi

  AGE_KEY="$(nix shell nixpkgs#ssh-to-age -c ssh-to-age <"$key.pub")"
  [ -n "$AGE_KEY" ] || die "could not derive the age key from $key.pub."

  while ! sops_ready; do
    echo
    warn "The machine key is not a sops recipient yet. Machine age key:"
    echo
    echo "    $AGE_KEY"
    echo
    echo "From WSL (where your personal age key is):"
    echo "  1. in .sops.yaml, uncomment the thinkpad-fahze lines and put this key;"
    echo "  2. nix shell nixpkgs#sops -c sops updatekeys secrets/secrets.yaml"
    echo "  3. git add .sops.yaml secrets/secrets.yaml && git commit && git push"
    echo
    read -rp "Press Enter once it is pushed (Ctrl-C to abort)... " _
    git_pull
  done
  info "The machine key is a sops recipient."
}

# ---------------------------------------------------------------------------
# Hardware configuration, install, finalisation
# ---------------------------------------------------------------------------

generate_hardware_config() {
  local hw="hosts/$HOST/hardware-configuration.nix"

  info "Generating $hw"
  run_sh "nixos-generate-config --root '$MNT' --show-hardware-config > '$REPO/$hw'"

  if $DRY_RUN; then
    warn "[dry-run] btrfs mount options would be added and LUKS in the initrd checked."
  else
    # The generator only writes subvol=...: add the compression and noatime options.
    sed -i -E "/fsType = \"btrfs\"/,/\};/ s/options = \[ \"subvol=([^\"]*)\" \];/options = [ \"subvol=\\1\" \"compress=zstd\" \"noatime\" ];/" "$REPO/$hw"

    local n_btrfs n_opts
    n_btrfs="$(grep -c 'fsType = "btrfs"' "$REPO/$hw" || true)"
    n_opts="$(grep -c 'compress=zstd' "$REPO/$hw" || true)"
    [ "$n_btrfs" = "$n_opts" ] ||
      warn "Only $n_opts of $n_btrfs btrfs filesystems got compress=zstd,noatime: edit $hw by hand."

    grep -q "boot.initrd.luks.devices" "$REPO/$hw" ||
      die "$hw has no boot.initrd.luks.devices entry: the system would not unlock the disk. Check that '$MAPPER_NAME' is open and mounted."
    grep -q 'fsType = "vfat"' "$REPO/$hw" || die "$hw has no vfat filesystem (/boot)."
  fi

  # Nix only sees git-tracked files.
  run git -C "$REPO" add -f "$hw"
}

install_system() {
  info "Installing $HOST (this takes a while)"
  # --no-root-passwd: root is locked, the password of $USERNAME comes from sops.
  run_sh "cd '$REPO' && nixos-install --root '$MNT' --flake '.#$HOST' --no-root-passwd"
}

copy_repo_to_home() {
  local dest="$MNT/home/$USERNAME/NixOS" uid="" gid=""

  info "Copying the repository to ~/NixOS"
  run mkdir -p "$MNT/home/$USERNAME"
  run cp -a "$REPO" "$dest"

  # Users are created at the first boot (immutable users): fall back to the
  # NixOS defaults for the first normal user (uid 1000, group users = 100).
  if [ -f "$MNT/etc/passwd" ] && ! $DRY_RUN; then
    uid="$(awk -F: -v u="$USERNAME" '$1 == u { print $3 }' "$MNT/etc/passwd")"
    gid="$(awk -F: -v u="$USERNAME" '$1 == u { print $4 }' "$MNT/etc/passwd")"
  fi
  uid="${uid:-1000}"
  gid="${gid:-100}"
  run chown -R "$uid:$gid" "$MNT/home/$USERNAME"
}

finish() {
  info "Installation complete"
  cat <<EOF

Next steps:
  1. Unmount and reboot (this script can do it below), then remove the USB stick.
  2. Unlock the disk (LUKS passphrase) and log in as '$USERNAME'.
  3. If ~/NixOS is not owned by you:  sudo chown -R $USERNAME:users ~/NixOS
  4. Commit the generated hardware configuration:
       cd ~/NixOS && git add hosts/$HOST/hardware-configuration.nix \\
         && git commit -m "feat(hosts): add the generated hardware configuration" && git push
  5. Enrol your fingerprint:  fprintd-enroll   then   fprintd-verify
  6. Run the checklist in docs/INSTALL.md (section E3).
EOF

  if $DRY_RUN; then return; fi
  local answer
  read -rp "Unmount $MNT and close the encrypted volume now? [Y/n] " answer
  if [[ ! "$answer" =~ ^[nN]$ ]]; then
    run umount -R "$MNT"
    run cryptsetup close "$MAPPER_NAME"
    echo "You can reboot now."
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

export NIX_CONFIG="experimental-features = nix-command flakes"

info "Installer for $HOST"
$DRY_RUN && warn "DRY RUN: nothing will be changed."

check_environment

USERNAME="$(awk -F'"' '/^[[:space:]]*username[[:space:]]*=/ { print $2; exit }' "$REPO/hosts/$HOST/variables.nix")"
[ -n "$USERNAME" ] || die "could not read username from hosts/$HOST/variables.nix."

# The repository is owned by the live user while this script runs as root.
run git config --global --add safe.directory "$REPO"

select_disk
ask_layout
validate_sizes
confirm_plan

partition_and_format
setup_machine_key
generate_hardware_config
install_system
copy_repo_to_home
finish

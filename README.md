# Pi-hole DNS Kiosk Dashboard (systemd)

This bundle runs a local Pi-hole dashboard in Chromium kiosk mode on a Raspberry Pi.

> This project is **not** Pi-hole itself. You must install Pi-hole first:
> https://github.com/pi-hole/pi-hole
>
> This repository is only a **mini activity card UI** to quickly check DNS activity on a Raspberry Pi, especially useful with a small **3.5" LCD monitor**.

It starts:

1. `python3 -m http.server` (serves `/opt/pihole-kiosk` on `127.0.0.1:8088`)
2. Chromium in kiosk mode pointing at `http://127.0.0.1:8088/`

The dashboard uses Pi-hole API v6 style endpoints:

- `POST /api/auth`
- `GET /api/stats/summary` (with `X-FTL-SID` header)

## 3.5" LCD Driver Install (GPIO Displays)

If you are using a standard 3.5" GPIO-connected display (for example Waveshare, Elecrow, or Osoyoo), these commands usually work:

1. Clone the driver repository:

```bash
git clone https://github.com/goodtft/LCD-show.git
```

2. Enter the directory:

```bash
cd LCD-show/
```

3. Run the installation script:

```bash
sudo ./LCD35-show
```

Note: the Raspberry Pi usually reboots automatically after running this command.

## Bill of Materials (Amazon)

1. Part 1: https://www.amazon.com/gp/product/B0CLV6WB4L/
2. Part 2: https://www.amazon.com/gp/product/B0D1XXW9MF/
3. Part 3: https://www.amazon.com/gp/product/B0CK2FCG1K/

## Install (Raspberry Pi OS Desktop)

1. Install dependencies:

```bash
sudo apt update
sudo apt -y install chromium python3 git
```

2. Copy files to `/opt/pihole-kiosk`:

```bash
sudo mkdir -p /opt/pihole-kiosk
sudo cp index.html pihole-kiosk.sh pihole-kiosk.service aid.txt ip.txt /opt/pihole-kiosk/
sudo chmod +x /opt/pihole-kiosk/pihole-kiosk.sh
sudo chown -R admin:admin /opt/pihole-kiosk
sudo chmod 600 /opt/pihole-kiosk/aid.txt
```

Notes:

- `aid.txt` must contain the Pi-hole admin password.
- `ip.txt` is overwritten automatically at startup using detected IPv4 (or `unknown` if no address is available yet).
- The local HTTP server is managed by the kiosk script and is cleaned up automatically when the kiosk process exits.

3. Install the systemd service:

```bash
sudo cp pihole-kiosk.service /etc/systemd/system/pihole-kiosk.service
```

If your Linux username is not `admin`, edit the service before enabling it:

- `User=`
- `Group=`
- `XAUTHORITY=/home/<user>/.Xauthority`

Then enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now pihole-kiosk.service
```

4. Reboot (optional):

```bash
sudo reboot
```

## Manage

```bash
sudo systemctl status pihole-kiosk
sudo systemctl restart pihole-kiosk
sudo journalctl -u pihole-kiosk -f --no-pager
```

## Uninstall

```bash
sudo systemctl disable --now pihole-kiosk
sudo rm -f /etc/systemd/system/pihole-kiosk.service
sudo systemctl daemon-reload
sudo rm -rf /opt/pihole-kiosk
```

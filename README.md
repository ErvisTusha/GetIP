# 🌐 Get-IP - Network Interface IP Tool

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Bash](https://img.shields.io/badge/bash-%3E%3D4.0-orange.svg)

An easy-to-use bash script for retrieving and displaying IP addresses for network interfaces with support for both IPv4 and IPv6 addresses.

<p align="center">
  <img src="https://raw.githubusercontent.com/ErvisTusha/GetIP/main/assets/logo.jpg" alt="Get IP Logo" width="600"/>
</p>

## ✨ Features

- 🌐 Supports both IPv4 and IPv6 addresses
- 🖥️ List all network interfaces
- ⚙️ Display IP addresses for specific interfaces
- 📋 Raw output mode for scripting
- 🛠️ Easy installation and update options

## Installation

```bash
# Direct installation
curl -sSL https://raw.githubusercontent.com/ErvisTusha/GetIP/main/getip.sh | sudo bash -s install

# Or clone and install
git clone https://github.com/ErvisTusha/GetIP.git
cd GetIP
./getip.sh install
```

### Basic Usage

```bash
# Display IP addresses for all interfaces
getip.sh

# Display IP addresses for a specific interface
getip.sh eth0

# List all network interfaces
getip.sh --list

# Display only IPv4 addresses
getip.sh eth0 -4

# Display only IPv6 addresses
getip.sh eth0 -6

# Display raw IP addresses (no formatting)
getip.sh eth0 -4 --raw
```

## 🎯 Command Line Options

```
Options:
    -h, --help          | Show this help message
    -v, --version       | Show version information
    -l, --list          | List all network interfaces
    --raw               | Display IP addresses only (no formatting)
    -4                  | Show IPv4 addresses only (default)
    -6                  | Show IPv6 addresses only
    install             | Install script to /usr/local/bin
    update              | Update to latest version
    uninstall           | Remove script from system
```

## 🔧 Requirements

- Bash shell
- `ip` command (from `iproute2` package)
- `awk` command (preferably GNU Awk)

## 🏗️ Development

This script was developed using:

- VSCode as the primary IDE
- Claude 3.5 Sonnet for AI assistance
- Modern bash scripting practices

### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

Distributed under the MIT License. See `LICENSE` file for more information.

## 👤 Author

**Ervis Tusha**

- X: [@ET](https://x.com/ET)
- GitHub: [@ErvisTusha](https://github.com/ErvisTusha)

## 🙏 Acknowledgments

- VSCode team for the excellent IDE
- The open-source community for inspiration

---

<p align="center">
  Made with ❤️ by Ervis Tusha
</p>

# Unix Health Watch
A Bash script that monitors the performance of a Linux system by checking the CPU, memory, and disk usage and sending an email alert if any of the thresholds are exceeded.

## Prerequisites

- `ssmtp`
- `mailutils`
- `mutt`
- Gmail account and app password ([https://myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords))

## Installation

To install, simply clone this repository to your Unix-based system and run the `install_config.sh` script.

```bash
$ git clone <repository-url>
$ cd <repository-directory>
$ ./install_config.sh
```
This will install the necessary dependencies and prompt for configuring ssmtp with your gmail credentials.

## Usage

Once the dependencies are installed, simply run the `start_sys_check.sh` script to begin monitoring your system. The script will run in the background and periodically log usage data to the `usage.log` file. If any usage thresholds are exceeded, an email alert will be sent to the configured email address.

```bash
$ ./start_sys_check.sh
```
# arch-installscript

## About

Arch Linuxインストール用スクリプトです。
以下の環境を想定しています。

- Partition
  - UEFI + rootの2つ
- Boot loader
  - systemd-boot UEFI

一先ずサーバ用途でCUIのみ。

## DEありバージョン準備中

### gnome

時刻表記を日本のフォーマットにすると、12:00の[:]が(RATIO U+2236)文字化けして豆腐になります。

とりあえずログイン前の時刻表記は/etc/locale.confでLC_TIMEをen_USにして、ログイン後はclocl overrideでいい感じにできます。

## Warning

このスクリプトは未完成です。

## Usage

```
# wget https://raw.githubusercontent.com/orlea/arch-installscript/master/install.sh
# chmod +x install.sh
# ./install.sh
```


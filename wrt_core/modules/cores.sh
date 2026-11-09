#!/usr/bin/env bash
# PassWall 内核二进制与 geo 数据：随固件内置，覆盖 feed 中的旧版本。

CORE_XRAY_ARCHIVE="xray-26.11.9-linux-arm64-v8a.tar.gz"
CORE_SINGBOX_ARCHIVE="sing-box-1.14.4-linux-arm64-musl.tar.gz"
CORE_SINGBOX_DIR="sing-box-1.14.4-linux-arm64-musl"


install_custom_cores() {
    local cores_dir="$BASE_PATH/patches/cores"
    local dest_dir="$BUILD_DIR/files"
    local tmp_dir

    if [ ! -f "$cores_dir/$CORE_XRAY_ARCHIVE" ] || [ ! -f "$cores_dir/$CORE_SINGBOX_ARCHIVE" ]; then
        echo "错误：缺少内核归档文件，请检查 $cores_dir" >&2
        return 1
    fi

    tmp_dir=$(mktemp -d)

    if ! tar -xzf "$cores_dir/$CORE_XRAY_ARCHIVE" -C "$tmp_dir" ||
        ! tar -xzf "$cores_dir/$CORE_SINGBOX_ARCHIVE" -C "$tmp_dir"; then
        rm -rf "$tmp_dir"
        echo "错误：解压内核归档失败" >&2
        return 1
    fi

    mkdir -p "$dest_dir/usr/bin" "$dest_dir/usr/share/v2ray"

    if ! install -m 0755 "$tmp_dir/xray" "$dest_dir/usr/bin/xray" ||
        ! install -m 0755 "$tmp_dir/$CORE_SINGBOX_DIR/sing-box" "$dest_dir/usr/bin/sing-box" ||
        ! install -m 0644 "$tmp_dir/geoip.dat" "$tmp_dir/geosite.dat" "$dest_dir/usr/share/v2ray/"; then
        rm -rf "$tmp_dir"
        echo "错误：写入内核二进制失败" >&2
        return 1
    fi

    rm -rf "$tmp_dir"
    echo "已内置 Xray 与 Sing-Box 二进制及 geo 数据到 $dest_dir"
}

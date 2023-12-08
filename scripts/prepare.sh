###
# @Author: zhkong
# @Date: 2023-07-25 17:07:02
 # @LastEditors: zhkong
 # @LastEditTime: 2023-12-04 12:24:40
 # @FilePath: /xiaomi-ax3600-openwrt-build/scripts/prepare.sh
###

git clone https://github.com/AgustinLorenzo/openwrt.git -b main --single-branch openwrt --depth 1
cd openwrt

# 增加ax3600 stock布局
git remote add upstream https://github.com/zhkong/openwrt-ipq807x.git
git fetch upstream xiaomi-ax3600-stock-layout --depth 3
git cherry-pick e2bb765
git cherry-pick 6f6eb1d
#如果checkout失败，说明有冲突，停止编译
if [ $? -ne 0 ]; then
    echo "cherry-pick failed, please check"
    exit 1
fi

# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# Zerotier
git clone https://github.com/mwarning/zerotier-openwrt --single-branch --depth 1 package/new/luci-zerotier

# AutoCore
svn export https://github.com/immortalwrt/immortalwrt/branches/master/package/emortal/autocore package/new/autocore
sed -i 's/"getTempInfo" /"getTempInfo", "getCPUBench", "getCPUUsage" /g' package/new/autocore/files/luci-mod-status-autocore.json

rm -rf feeds/luci/modules/luci-base
rm -rf feeds/luci/modules/luci-mod-status
rm -rf feeds/packages/utils/coremark
rm -rf package/emortal/default-settings

svn export https://github.com/immortalwrt/luci/branches/master/modules/luci-base feeds/luci/modules/luci-base
svn export https://github.com/immortalwrt/luci/branches/master/modules/luci-mod-status feeds/luci/modules/luci-mod-status
svn export https://github.com/immortalwrt/packages/branches/master/utils/coremark package/new/coremark
svn export https://github.com/immortalwrt/immortalwrt/branches/master/package/emortal/default-settings package/emortal/default-settings


# config file
cp ../config/xiaomi_ax3600-stock.config .config
make defconfig

# # 编译固件
# make download -j$(nproc)
# make -j$(nproc) || make -j1 V=s

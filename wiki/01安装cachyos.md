# 跟着引导

###  分区


    这一步是重点，根据需求选择。
    
    - install alongside （并存）
    
        如果你是一个盘装 Win + Cachy 双系统，进 Live 环境前没有事先腾出硬盘空间，且 Win 的 EFI 分区大于 512MB，选择这一项。
    
    - replace a partition （替代一个分区）
    
        如果你是一个盘装 Win + Cachy 双系统，进 Live 环境前事先腾出了硬盘空间，且 Win 的 EFI 分区大于 512MB，选择这一项。
    
    - erase disk （抹掉磁盘）
    
        如果你使用一整个硬盘安装 Cachy，选择这一项。
    
    - manual partitioning（手动分区）
    
        如果以上都不满足，选这一项。

###  手动分区

    分出两个分区，一个启动分区，一个根分区。
    
    - 选择空闲空间，点击 create 创建。
    
    - 新建启动分区
    
        CachyOS 要求启动分区 Size（大小）至少为 `512MB`，FileSystem（文件系统）为 `fat32`，MountPoint（挂载点）为 `/boot/efi`，Flags（标记）为 `boot`。
    
    - 新建根分区
    
        剩下的空闲空间都是根分区，文件系统推荐 `btrfs`，挂载点为 `/`。

桌面选择niri

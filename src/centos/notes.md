### CentOS

- https://cloud.centos.org/centos/8/x86_64/images/


wget https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-ec2-8.4.2105-20210603.0.x86_64.qcow2


qemu-img info


```bash
qemu-kvm \
-m 512 \
-nic user \
-boot d \
-hda CentOS-8-ec2-8.4.2105-20210603.0.x86_64.qcow2 \
-nographic \
-enable-kvm \
-cpu host \
-smp $(nproc)
```

# NFS Server Setup

## Overview
The NFS (Network File System) server is a crucial component in our Hyperledger Fabric network setup. It provides shared storage for all network components, ensuring data consistency and availability across the Kubernetes cluster.

## Prerequisites
- Kubernetes cluster
- NFS server package installed
- Sufficient storage space
- Network connectivity between nodes

## Installation Steps

### 1. Install NFS Server
```bash
# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install nfs-kernel-server

# For CentOS/RHEL
sudo yum install nfs-utils
```

### 2. Create NFS Directory
```bash
sudo mkdir -p /data/hyperledger
sudo chown nobody:nogroup /data/hyperledger
sudo chmod 777 /data/hyperledger
```

### 3. Configure NFS Exports
```bash
# Edit /etc/exports
sudo echo "/data/hyperledger *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports

# Apply changes
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
```

### 4. Verify NFS Setup
```bash
# Check NFS status
sudo systemctl status nfs-kernel-server

# List exports
sudo exportfs -v
```

## Directory Structure
```
/data/hyperledger/
├── organizations/     # Organization certificates and keys
├── artifacts/        # Network artifacts
├── chaincode/        # Chaincode packages
└── data/            # Persistent data
```

## Security Considerations
1. Network Security
   - Restrict NFS access to Kubernetes nodes only
   - Use firewall rules to limit access
   - Consider using NFSv4 with Kerberos

2. File Permissions
   - Set appropriate ownership
   - Configure proper access rights
   - Regular permission audits

## Troubleshooting

### Common Issues
1. Permission Denied
   ```bash
   # Check NFS server logs
   sudo tail -f /var/log/syslog | grep nfs
   
   # Verify exports
   sudo showmount -e localhost
   ```

2. Connection Issues
   ```bash
   # Check NFS service
   sudo systemctl status nfs-kernel-server
   
   # Verify network connectivity
   ping <nfs-server-ip>
   ```

### Performance Tuning
1. NFS Server Configuration
   ```bash
   # Edit /etc/default/nfs-kernel-server
   RPCNFSDCOUNT=8
   ```

2. Client Mount Options
   ```bash
   # Optimize mount options
   mount -t nfs4 -o rw,hard,timeo=600,retrans=2,noresvport <server>:/data/hyperledger /mnt
   ```

## Backup and Recovery
1. Regular Backups
   ```bash
   # Create backup script
   #!/bin/bash
   tar -czf /backup/hyperledger-$(date +%Y%m%d).tar.gz /data/hyperledger
   ```

2. Recovery Procedure
   ```bash
   # Restore from backup
   tar -xzf /backup/hyperledger-backup.tar.gz -C /data/
   ```

## Monitoring
1. Resource Usage
   ```bash
   # Monitor disk usage
   df -h /data/hyperledger
   
   # Check NFS statistics
   nfsstat
   ```

2. Performance Metrics
   - I/O operations
   - Network throughput
   - Response times

## Maintenance
1. Regular Tasks
   - Check disk space
   - Monitor system logs
   - Update NFS packages
   - Review security settings

2. Health Checks
   ```bash
   # Check NFS service
   sudo systemctl status nfs-kernel-server
   
   # Verify exports
   sudo exportfs -v
   ```

## Best Practices
1. Security
   - Use NFSv4
   - Implement proper authentication
   - Regular security audits

2. Performance
   - Optimize mount options
   - Monitor resource usage
   - Regular maintenance

3. Backup
   - Regular backups
   - Test recovery procedures
   - Document backup/restore processes 
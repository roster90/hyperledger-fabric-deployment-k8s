# Orderer Deployment

## Overview
This document describes the deployment and configuration of the Orderer service in the Hyperledger Fabric network. The Orderer is responsible for transaction ordering and block creation.

## Architecture
- Raft consensus
- Multiple orderer nodes for high availability
- TLS enabled
- Persistent storage via NFS

## Prerequisites
- Kubernetes cluster
- NFS server configured
- Certificates generated
- Genesis block created
- kubectl configured

## Deployment Steps

### 1. Prepare Orderer Configuration
```bash
# Create orderer configuration directory
mkdir -p organizations/orderer/orderers/orderer.example.com
```

### 2. Deploy Orderer Services
```bash
# Deploy orderer nodes
kubectl apply -f 5.orderer/orderer.yaml
kubectl apply -f 5.orderer/orderer-service.yaml

# Deploy orderer admin
kubectl apply -f 5.orderer/orderer-admin.yaml
```

### 3. Verify Orderer Deployment
```bash
# Check orderer pods
kubectl get pods -l app=orderer

# Check orderer services
kubectl get svc -l app=orderer

# Check orderer logs
kubectl logs -f <orderer-pod-name>
```

## Configuration

### 1. Orderer Configuration
```yaml
# orderer.yaml
General:
  ListenAddress: 0.0.0.0
  ListenPort: 7050
  TLS:
    Enabled: true
    PrivateKey: /etc/hyperledger/fabric/tls/server.key
    Certificate: /etc/hyperledger/fabric/tls/server.crt
    RootCAs:
      - /etc/hyperledger/fabric/tls/ca.crt
  Cluster:
    ListenAddress: 0.0.0.0
    ListenPort: 7051
    ServerCertificate: /etc/hyperledger/fabric/tls/server.crt
    ServerPrivateKey: /etc/hyperledger/fabric/tls/server.key
    ClientCertificate: /etc/hyperledger/fabric/tls/server.crt
    ClientPrivateKey: /etc/hyperledger/fabric/tls/server.key
    RootCAs:
      - /etc/hyperledger/fabric/tls/ca.crt
```

### 2. Raft Configuration
```yaml
Consensus:
  WALDir: /var/hyperledger/production/orderer/etcdraft/wal
  SnapDir: /var/hyperledger/production/orderer/etcdraft/snapshot
  EvictionSuspicion: 10s
```

## Security Considerations

### 1. TLS Configuration
- Enable TLS for all communications
- Use strong encryption
- Regular certificate rotation

### 2. Access Control
- Implement proper authentication
- Use role-based access control
- Regular access audits

### 3. Network Security
- Use network policies
- Restrict access to orderer ports
- Monitor network traffic

## Troubleshooting

### Common Issues
1. Orderer Pod Not Starting
   ```bash
   # Check pod status
   kubectl describe pod <orderer-pod-name>
   
   # Check logs
   kubectl logs -f <orderer-pod-name>
   ```

2. Consensus Issues
   ```bash
   # Check Raft status
   kubectl exec <orderer-pod-name> -- etcdctl cluster-health
   
   # Check orderer metrics
   curl -k https://localhost:8443/metrics
   ```

### Health Checks
```bash
# Check orderer health
curl -k https://localhost:8443/healthz

# Check orderer metrics
curl -k https://localhost:8443/metrics
```

## Monitoring

### 1. Metrics to Monitor
- Block creation rate
- Transaction processing rate
- Consensus metrics
- Resource usage

### 2. Logging
- Enable debug logging when needed
- Regular log rotation
- Log analysis

## Backup and Recovery

### 1. Backup Procedure
```bash
# Backup orderer data
kubectl exec <orderer-pod-name> -- tar -czf /backup/orderer-backup.tar.gz /var/hyperledger/production/orderer
```

### 2. Recovery Procedure
```bash
# Restore orderer data
kubectl exec <orderer-pod-name> -- tar -xzf /backup/orderer-backup.tar.gz -C /var/hyperledger/production/orderer
```

## Best Practices

### 1. Security
- Regular security audits
- Keep orderer software updated
- Implement proper access controls

### 2. Performance
- Monitor resource usage
- Optimize consensus configuration
- Regular maintenance

### 3. High Availability
- Deploy multiple orderer nodes
- Implement proper backup strategies
- Document recovery procedures

## Maintenance

### 1. Regular Tasks
- Check orderer logs
- Monitor resource usage
- Update orderer software
- Review security settings

### 2. Health Checks
```bash
# Check orderer status
kubectl get pods -l app=orderer

# Check orderer logs
kubectl logs -f <orderer-pod-name>
```

## API Reference

### 1. Orderer API
- `/healthz` - Health check endpoint
- `/metrics` - Metrics endpoint
- `/debug/vars` - Debug information

### 2. CLI Commands
```bash
# Check orderer status
osnadmin channel list -o localhost:7050 --ca-file /path/to/ca.crt --client-cert /path/to/client.crt --client-key /path/to/client.key

# Join channel
osnadmin channel join -o localhost:7050 --channelID mychannel --config-block /path/to/genesis.block --ca-file /path/to/ca.crt --client-cert /path/to/client.crt --client-key /path/to/client.key
``` 
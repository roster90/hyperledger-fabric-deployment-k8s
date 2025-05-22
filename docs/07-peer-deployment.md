# Peer Deployment

## Overview
This document describes the deployment and configuration of Peer nodes in the Hyperledger Fabric network. Peers are the fundamental network nodes that maintain the ledger and run chaincode.

## Architecture
- Multiple peers per organization
- CouchDB for state database
- TLS enabled
- Persistent storage via NFS
- Gossip protocol for peer communication

## Prerequisites
- Kubernetes cluster
- NFS server configured
- Certificates generated
- Channel artifacts created
- ConfigMaps configured
- kubectl configured

## Deployment Steps

### 1. Prepare Peer Configuration
```bash
# Create peer configuration directories
mkdir -p organizations/org1/peers/peer0.org1.example.com
mkdir -p organizations/org2/peers/peer0.org2.example.com
mkdir -p organizations/org3/peers/peer0.org3.example.com
```

### 2. Deploy CouchDB
```bash
# Deploy CouchDB for each peer
kubectl apply -f 7.peers/org1/couchdb.yaml
kubectl apply -f 7.peers/org2/couchdb.yaml
kubectl apply -f 7.peers/org3/couchdb.yaml
```

### 3. Deploy Peers
```bash
# Deploy Org1 peers
kubectl apply -f 7.peers/org1/peer0.yaml
kubectl apply -f 7.peers/org1/peer0-service.yaml

# Deploy Org2 peers
kubectl apply -f 7.peers/org2/peer0.yaml
kubectl apply -f 7.peers/org2/peer0-service.yaml

# Deploy Org3 peers
kubectl apply -f 7.peers/org3/peer0.yaml
kubectl apply -f 7.peers/org3/peer0-service.yaml
```

### 4. Verify Peer Deployment
```bash
# Check peer pods
kubectl get pods -l app=peer

# Check peer services
kubectl get svc -l app=peer

# Check peer logs
kubectl logs -f <peer-pod-name>
```

## Configuration

### 1. Peer Configuration
```yaml
# peer-core.yaml
core:
  peer:
    id: peer0.org1.example.com
    address: 0.0.0.0:7051
    listenAddress: 0.0.0.0:7051
    chaincodeAddress: 0.0.0.0:7052
    chaincodeListenAddress: 0.0.0.0:7052
    gossip:
      bootstrap: peer0.org1.example.com:7051
      externalEndpoint: peer0.org1.example.com:7051
    mspConfigPath: /etc/hyperledger/fabric/msp
    localMspId: Org1MSP
    tls:
      enabled: true
      cert:
        file: /etc/hyperledger/fabric/tls/server.crt
      key:
        file: /etc/hyperledger/fabric/tls/server.key
      rootcert:
        file: /etc/hyperledger/fabric/tls/ca.crt
```

### 2. CouchDB Configuration
```yaml
# couchdb.yaml
apiVersion: v1
kind: Service
metadata:
  name: couchdb0
spec:
  selector:
    app: couchdb
  ports:
    - port: 5984
      targetPort: 5984
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: couchdb0
spec:
  selector:
    matchLabels:
      app: couchdb
  template:
    metadata:
      labels:
        app: couchdb
    spec:
      containers:
        - name: couchdb
          image: couchdb:3.1.1
          ports:
            - containerPort: 5984
          env:
            - name: COUCHDB_USER
              value: admin
            - name: COUCHDB_PASSWORD
              value: adminpw
```

## Channel Operations

### 1. Create Channel
```bash
# Create channel
peer channel create -o orderer.example.com:7050 \
    -c mychannel \
    -f ./artifacts/channel.tx \
    --tls --cafile /etc/hyperledger/fabric/tls/ca.crt
```

### 2. Join Channel
```bash
# Join channel
peer channel join -b mychannel.block \
    --tls --cafile /etc/hyperledger/fabric/tls/ca.crt
```

### 3. Update Anchor Peers
```bash
# Update anchor peers
peer channel update -o orderer.example.com:7050 \
    -c mychannel \
    -f ./artifacts/Org1MSPanchors.tx \
    --tls --cafile /etc/hyperledger/fabric/tls/ca.crt
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
- Restrict access to peer ports
- Monitor network traffic

## Troubleshooting

### Common Issues
1. Peer Pod Not Starting
   ```bash
   # Check pod status
   kubectl describe pod <peer-pod-name>
   
   # Check logs
   kubectl logs -f <peer-pod-name>
   ```

2. Channel Issues
   ```bash
   # Check channel list
   peer channel list --tls --cafile /etc/hyperledger/fabric/tls/ca.crt
   
   # Check channel info
   peer channel getinfo -c mychannel --tls --cafile /etc/hyperledger/fabric/tls/ca.crt
   ```

### Health Checks
```bash
# Check peer health
curl -k https://localhost:9443/healthz

# Check peer metrics
curl -k https://localhost:9443/metrics
```

## Monitoring

### 1. Metrics to Monitor
- Block processing rate
- Transaction processing rate
- Chaincode execution metrics
- Resource usage

### 2. Logging
- Enable debug logging when needed
- Regular log rotation
- Log analysis

## Backup and Recovery

### 1. Backup Procedure
```bash
# Backup peer data
kubectl exec <peer-pod-name> -- tar -czf /backup/peer-backup.tar.gz /var/hyperledger/production

# Backup CouchDB data
kubectl exec <couchdb-pod-name> -- tar -czf /backup/couchdb-backup.tar.gz /opt/couchdb/data
```

### 2. Recovery Procedure
```bash
# Restore peer data
kubectl exec <peer-pod-name> -- tar -xzf /backup/peer-backup.tar.gz -C /var/hyperledger/production

# Restore CouchDB data
kubectl exec <couchdb-pod-name> -- tar -xzf /backup/couchdb-backup.tar.gz -C /opt/couchdb/data
```

## Best Practices

### 1. Security
- Regular security audits
- Keep peer software updated
- Implement proper access controls

### 2. Performance
- Monitor resource usage
- Optimize CouchDB configuration
- Regular maintenance

### 3. High Availability
- Deploy multiple peers per org
- Implement proper backup strategies
- Document recovery procedures

## Maintenance

### 1. Regular Tasks
- Check peer logs
- Monitor resource usage
- Update peer software
- Review security settings

### 2. Health Checks
```bash
# Check peer status
kubectl get pods -l app=peer

# Check peer logs
kubectl logs -f <peer-pod-name>
```

## API Reference

### 1. Peer API
- `/healthz` - Health check endpoint
- `/metrics` - Metrics endpoint
- `/debug/vars` - Debug information

### 2. CLI Commands
```bash
# Channel operations
peer channel create -o <orderer> -c <channel> -f <tx>
peer channel join -b <block>
peer channel update -o <orderer> -c <channel> -f <tx>

# Chaincode operations
peer chaincode install -n <name> -v <version> -p <path>
peer chaincode instantiate -o <orderer> -C <channel> -n <name> -v <version> -c <args>
``` 
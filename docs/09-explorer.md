# Hyperledger Explorer Setup

## Overview
This document describes the setup and configuration of Hyperledger Explorer, a web application for monitoring and visualizing Hyperledger Fabric networks.

## Prerequisites
- Kubernetes cluster
- PostgreSQL database
- Fabric network running
- Access to peer and orderer nodes
- TLS certificates
- kubectl configured

## Architecture
- Web application frontend
- Backend API service
- PostgreSQL database
- TLS enabled
- Persistent storage

## Deployment Steps

### 1. Prepare Configuration
```bash
# Create explorer configuration directory
mkdir -p explorer/config
mkdir -p explorer/crypto
```

### 2. Configure Database
```yaml
# postgresql.yaml
apiVersion: v1
kind: Service
metadata:
  name: postgresql
spec:
  selector:
    app: postgresql
  ports:
    - port: 5432
      targetPort: 5432
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql
spec:
  selector:
    matchLabels:
      app: postgresql
  template:
    metadata:
      labels:
        app: postgresql
    spec:
      containers:
        - name: postgresql
          image: postgres:13
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_USER
              value: hlfexplorer
            - name: POSTGRES_PASSWORD
              value: hlfexplorer
            - name: POSTGRES_DB
              value: fabricexplorer
          volumeMounts:
            - name: postgresql-data
              mountPath: /var/lib/postgresql/data
      volumes:
        - name: postgresql-data
          persistentVolumeClaim:
            claimName: postgresql-pvc
```

### 3. Deploy Explorer
```yaml
# explorer.yaml
apiVersion: v1
kind: Service
metadata:
  name: explorer
spec:
  selector:
    app: explorer
  ports:
    - port: 8080
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: explorer
spec:
  selector:
    matchLabels:
      app: explorer
  template:
    metadata:
      labels:
        app: explorer
    spec:
      containers:
        - name: explorer
          image: hyperledger/explorer:latest
          ports:
            - containerPort: 8080
          env:
            - name: DATABASE_HOST
              value: postgresql
            - name: DATABASE_DATABASE
              value: fabricexplorer
            - name: DATABASE_USERNAME
              value: hlfexplorer
            - name: DATABASE_PASSWORD
              value: hlfexplorer
            - name: LOG_LEVEL
              value: debug
          volumeMounts:
            - name: crypto-config
              mountPath: /opt/explorer/crypto
            - name: config
              mountPath: /opt/explorer/config
      volumes:
        - name: crypto-config
          secret:
            secretName: crypto-config
        - name: config
          configMap:
            name: explorer-config
```

### 4. Configure Network Connection
```json
// config.json
{
  "network-configs": {
    "network-1": {
      "name": "Network 1",
      "profile": "./connection-profile/network1.yaml"
    }
  },
  "license": "Apache-2.0"
}
```

### 5. Create Connection Profile
```yaml
# connection-profile/network1.yaml
name: "Network1"
version: "1.0.0"
client:
  organization: Org1
  connection:
    timeout:
      peer:
        endorser: '300'
        eventHub: '300'
        eventReg: '300'
      orderer: '300'
channels:
  mychannel:
    orderers:
      - orderer.example.com
    peers:
      peer0.org1.example.com:
        endorsingPeer: true
        chaincodeQuery: true
        ledgerQuery: true
        eventSource: true
organizations:
  Org1:
    mspid: Org1MSP
    peers:
      - peer0.org1.example.com
    certificateAuthorities:
      - ca.org1.example.com
orderers:
  orderer.example.com:
    url: grpcs://orderer.example.com:7050
    tlsCACerts:
      path: /opt/explorer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
peers:
  peer0.org1.example.com:
    url: grpcs://peer0.org1.example.com:7051
    tlsCACerts:
      path: /opt/explorer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
certificateAuthorities:
  ca.org1.example.com:
    url: https://ca.org1.example.com:7054
    tlsCACerts:
      path: /opt/explorer/crypto/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem
```

### 6. Deploy Services
```bash
# Deploy PostgreSQL
kubectl apply -f postgresql.yaml

# Deploy Explorer
kubectl apply -f explorer.yaml

# Verify deployment
kubectl get pods -l app=explorer
kubectl get svc -l app=explorer
```

## Configuration

### 1. Database Configuration
```yaml
# Database settings
DATABASE_HOST: postgresql
DATABASE_DATABASE: fabricexplorer
DATABASE_USERNAME: hlfexplorer
DATABASE_PASSWORD: hlfexplorer
```

### 2. Explorer Configuration
```yaml
# Explorer settings
PORT: 8080
LOG_LEVEL: debug
DISCOVERY_AS_LOCALHOST: false
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
- Restrict access to explorer ports
- Monitor network traffic

## Troubleshooting

### Common Issues
1. Database Connection
   ```bash
   # Check database logs
   kubectl logs -f <postgresql-pod-name>
   
   # Check database connection
   kubectl exec -it <postgresql-pod-name> -- psql -U hlfexplorer -d fabricexplorer
   ```

2. Explorer Issues
   ```bash
   # Check explorer logs
   kubectl logs -f <explorer-pod-name>
   
   # Check explorer status
   curl -k https://localhost:8080/api/health
   ```

## Monitoring

### 1. Metrics to Monitor
- API response times
- Database performance
- Resource usage
- Error rates

### 2. Logging
- Enable debug logging when needed
- Regular log rotation
- Log analysis

## Backup and Recovery

### 1. Backup Procedure
```bash
# Backup database
kubectl exec <postgresql-pod-name> -- pg_dump -U hlfexplorer fabricexplorer > backup.sql

# Backup configuration
kubectl get configmap explorer-config -o yaml > config-backup.yaml
```

### 2. Recovery Procedure
```bash
# Restore database
kubectl exec -i <postgresql-pod-name> -- psql -U hlfexplorer fabricexplorer < backup.sql

# Restore configuration
kubectl apply -f config-backup.yaml
```

## Best Practices

### 1. Security
- Regular security audits
- Keep explorer software updated
- Implement proper access controls

### 2. Performance
- Monitor resource usage
- Optimize database configuration
- Regular maintenance

### 3. High Availability
- Deploy multiple instances
- Implement proper backup strategies
- Document recovery procedures

## Maintenance

### 1. Regular Tasks
- Check explorer logs
- Monitor resource usage
- Update explorer software
- Review security settings

### 2. Health Checks
```bash
# Check explorer status
kubectl get pods -l app=explorer

# Check explorer logs
kubectl logs -f <explorer-pod-name>
```

## API Reference

### 1. Explorer API
- `/api/health` - Health check endpoint
- `/api/blocks` - Block information
- `/api/transactions` - Transaction information
- `/api/channels` - Channel information

### 2. CLI Commands
```bash
# Check explorer status
curl -k https://localhost:8080/api/health

# Get block information
curl -k https://localhost:8080/api/blocks/1

# Get channel information
curl -k https://localhost:8080/api/channels
``` 
# Certificate Authority (CA) Deployment

## Overview
The Certificate Authority (CA) is a critical component in the Hyperledger Fabric network. It manages the identities of all participants in the network by issuing and managing certificates.

## Architecture
- One CA per organization (Org1, Org2, Org3)
- One CA for the Orderer organization
- Each CA runs as a Kubernetes deployment
- CAs use persistent storage via NFS

## Prerequisites
- Kubernetes cluster
- NFS server configured
- kubectl configured
- Fabric CA client installed

## Deployment Steps

### 1. Prepare CA Configuration
```bash
# Create CA configuration directory
mkdir -p organizations/fabric-ca/org1
mkdir -p organizations/fabric-ca/org2
mkdir -p organizations/fabric-ca/org3
mkdir -p organizations/fabric-ca/orderer
```

### 2. Deploy CA Services
```bash
# Deploy Org1 CA
kubectl apply -f 2.ca/ca-org1.yaml
kubectl apply -f 2.ca/ca-org1-service.yaml

# Deploy Org2 CA
kubectl apply -f 2.ca/ca-org2.yaml
kubectl apply -f 2.ca/ca-org2-service.yaml

# Deploy Org3 CA
kubectl apply -f 2.ca/ca-org3.yaml
kubectl apply -f 2.ca/ca-org3-service.yaml

# Deploy Orderer CA
kubectl apply -f 2.ca/ca-orderer.yaml
kubectl apply -f 2.ca/ca-orderer-service.yaml
```

### 3. Verify CA Deployment
```bash
# Check CA pods
kubectl get pods -l app=ca

# Check CA services
kubectl get svc -l app=ca

# Check CA logs
kubectl logs -f <ca-pod-name>
```

## CA Configuration

### 1. CA Server Configuration
```yaml
# Example CA server configuration
version: 1.4.0
port: 7054
debug: false
crlsizelimit: 512000
tls:
  enabled: true
  certfile: /etc/hyperledger/fabric-ca-server-config/ca.org1.example.com-cert.pem
  keyfile: /etc/hyperledger/fabric-ca-server-config/priv_sk
```

### 2. Database Configuration
```yaml
db:
  type: sqlite3
  datasource: /etc/hyperledger/fabric-ca-server/fabric-ca-server.db
```

## Security Considerations

### 1. TLS Configuration
- Enable TLS for all CA communications
- Use strong encryption
- Regular certificate rotation

### 2. Access Control
- Implement proper authentication
- Use role-based access control
- Regular access audits

### 3. Key Management
- Secure storage of private keys
- Regular key rotation
- Backup of key material

## Troubleshooting

### Common Issues
1. CA Pod Not Starting
   ```bash
   # Check pod status
   kubectl describe pod <ca-pod-name>
   
   # Check logs
   kubectl logs -f <ca-pod-name>
   ```

2. Certificate Issues
   ```bash
   # Verify certificate
   openssl x509 -in ca-cert.pem -text -noout
   
   # Check certificate chain
   openssl verify -CAfile ca-cert.pem cert.pem
   ```

### Health Checks
```bash
# Check CA health
curl -k https://localhost:7054/healthz

# Check CA metrics
curl -k https://localhost:7054/metrics
```

## Monitoring

### 1. Metrics to Monitor
- Certificate issuance rate
- Error rates
- Response times
- Resource usage

### 2. Logging
- Enable debug logging when needed
- Regular log rotation
- Log analysis

## Backup and Recovery

### 1. Backup Procedure
```bash
# Backup CA data
kubectl exec <ca-pod-name> -- tar -czf /backup/ca-backup.tar.gz /etc/hyperledger/fabric-ca-server
```

### 2. Recovery Procedure
```bash
# Restore CA data
kubectl exec <ca-pod-name> -- tar -xzf /backup/ca-backup.tar.gz -C /etc/hyperledger/fabric-ca-server
```

## Best Practices

### 1. Security
- Regular security audits
- Keep CA software updated
- Implement proper access controls

### 2. Performance
- Monitor resource usage
- Optimize database configuration
- Regular maintenance

### 3. High Availability
- Consider CA replication
- Implement proper backup strategies
- Document recovery procedures

## Maintenance

### 1. Regular Tasks
- Check CA logs
- Monitor resource usage
- Update CA software
- Review security settings

### 2. Health Checks
```bash
# Check CA status
kubectl get pods -l app=ca

# Check CA logs
kubectl logs -f <ca-pod-name>
```

## API Reference

### 1. REST API
- `/api/v1/register` - Register new identity
- `/api/v1/enroll` - Enroll identity
- `/api/v1/reenroll` - Re-enroll identity
- `/api/v1/revoke` - Revoke identity

### 2. CLI Commands
```bash
# Register new identity
fabric-ca-client register --id.name admin --id.secret adminpw --id.type admin

# Enroll identity
fabric-ca-client enroll -u http://admin:adminpw@localhost:7054

# Re-enroll identity
fabric-ca-client reenroll -u http://admin:adminpw@localhost:7054
``` 
# ConfigMap Configuration

## Overview
This document describes the configuration and management of Kubernetes ConfigMaps for the Hyperledger Fabric network. ConfigMaps store configuration data in key-value pairs and are used to configure various components of the network.

## Prerequisites
- Kubernetes cluster
- kubectl configured
- Access to cluster with appropriate permissions

## ConfigMap Types

### 1. Core ConfigMaps
- Orderer configuration
- Peer configuration
- Channel configuration
- Chaincode configuration

### 2. Organization ConfigMaps
- Organization MSP configuration
- Organization policies
- Organization capabilities

## Configuration Process

### 1. Create Core ConfigMaps
```bash
# Create orderer config
kubectl create configmap orderer-config \
    --from-file=configtx.yaml=./configtx.yaml \
    --from-file=core.yaml=./orderer/core.yaml

# Create peer config
kubectl create configmap peer-config \
    --from-file=core.yaml=./peer/core.yaml

# Create channel config
kubectl create configmap channel-config \
    --from-file=channel.tx=./artifacts/channel.tx
```

### 2. Create Organization ConfigMaps
```bash
# Create org1 config
kubectl create configmap org1-config \
    --from-file=msp=./organizations/org1/msp \
    --from-file=tls=./organizations/org1/tls

# Create org2 config
kubectl create configmap org2-config \
    --from-file=msp=./organizations/org2/msp \
    --from-file=tls=./organizations/org2/tls

# Create org3 config
kubectl create configmap org3-config \
    --from-file=msp=./organizations/org3/msp \
    --from-file=tls=./organizations/org3/tls
```

## ConfigMap Structure

### 1. Orderer Configuration
```yaml
# orderer-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: orderer-config
data:
  ORDERER_GENERAL_LISTENADDRESS: "0.0.0.0"
  ORDERER_GENERAL_LISTENPORT: "7050"
  ORDERER_GENERAL_TLS_ENABLED: "true"
  ORDERER_GENERAL_TLS_PRIVATEKEY: "/etc/hyperledger/fabric/tls/server.key"
  ORDERER_GENERAL_TLS_CERTIFICATE: "/etc/hyperledger/fabric/tls/server.crt"
  ORDERER_GENERAL_TLS_ROOTCAS: "[/etc/hyperledger/fabric/tls/ca.crt]"
```

### 2. Peer Configuration
```yaml
# peer-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: peer-config
data:
  CORE_PEER_ID: "peer0.org1.example.com"
  CORE_PEER_ADDRESS: "peer0.org1.example.com:7051"
  CORE_PEER_LISTENADDRESS: "0.0.0.0:7051"
  CORE_PEER_CHAINCODEADDRESS: "peer0.org1.example.com:7052"
  CORE_PEER_CHAINCODELISTENADDRESS: "0.0.0.0:7052"
  CORE_PEER_GOSSIP_BOOTSTRAP: "peer0.org1.example.com:7051"
  CORE_PEER_GOSSIP_EXTERNALENDPOINT: "peer0.org1.example.com:7051"
  CORE_PEER_LOCALMSPID: "Org1MSP"
```

## Security Considerations

### 1. Sensitive Data
- Avoid storing sensitive data in ConfigMaps
- Use Secrets for sensitive information
- Implement proper access controls

### 2. Access Control
- Use RBAC to control access
- Regular access audits
- Monitor ConfigMap changes

## Troubleshooting

### Common Issues
1. ConfigMap Not Found
   ```bash
   # Check ConfigMap existence
   kubectl get configmap <configmap-name>
   
   # Describe ConfigMap
   kubectl describe configmap <configmap-name>
   ```

2. Configuration Issues
   ```bash
   # Check pod logs
   kubectl logs -f <pod-name>
   
   # Check ConfigMap data
   kubectl get configmap <configmap-name> -o yaml
   ```

## Best Practices

### 1. Configuration Management
- Version control for configurations
- Document all changes
- Regular configuration reviews

### 2. Organization
- Clear naming conventions
- Logical grouping of configurations
- Proper documentation

### 3. Security
- Regular security audits
- Proper access controls
- Monitor configuration changes

## Maintenance

### 1. Regular Tasks
- Review configurations
- Update configurations as needed
- Monitor configuration usage

### 2. Health Checks
```bash
# Check ConfigMap status
kubectl get configmap

# Verify ConfigMap data
kubectl get configmap <configmap-name> -o yaml
```

## Backup and Recovery

### 1. Backup Procedure
```bash
# Backup ConfigMaps
kubectl get configmap -o yaml > configmaps-backup.yaml

# Backup specific ConfigMap
kubectl get configmap <configmap-name> -o yaml > <configmap-name>-backup.yaml
```

### 2. Recovery Procedure
```bash
# Restore ConfigMaps
kubectl apply -f configmaps-backup.yaml

# Restore specific ConfigMap
kubectl apply -f <configmap-name>-backup.yaml
```

## Monitoring

### 1. Configuration Monitoring
- Track configuration changes
- Monitor configuration usage
- Review configuration updates

### 2. Logging
- Log configuration changes
- Track configuration access
- Monitor configuration errors

## API Reference

### 1. kubectl Commands
```bash
# Create ConfigMap
kubectl create configmap <name> --from-file=<path>

# Update ConfigMap
kubectl create configmap <name> --from-file=<path> -o yaml --dry-run | kubectl replace -f -

# Delete ConfigMap
kubectl delete configmap <name>
```

### 2. ConfigMap Operations
```bash
# Get ConfigMap
kubectl get configmap <name>

# Describe ConfigMap
kubectl describe configmap <name>

# Edit ConfigMap
kubectl edit configmap <name>
``` 
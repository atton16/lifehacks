# Hyperledger BYFN

### Prerequisites
[Install Samples, Binaries and Docker Images ](https://hyperledger-fabric.readthedocs.io/en/release-1.2/install.html)

Execute `$ curl -sSL http://bit.ly/2ysbOFE | bash -s 1.2.0`

This will
      
1. Clone `fabric-samples` into current directory
2. Checkout the appropriate version tag
3. Install the Hyperledger Fabric platform-specific binaries and config files for the version specified into the root of the fabric-samples repository
         
   - List of platform-specific libraries inside `fabric-samples/bin`
         
     `cryptogen `, `configtxgen`, `configtxlator `, `peer`, `orderer`, `idemixgen`, `fabric-ca-client`
         
   - You may wanted to add these `bin` to your PATH
         
     `export PATH=<path to fabric-samples location>/bin:$PATH`
         
4. Download the Hyperledger Fabric docker images for the version specified

   - This includes `fabric-ca`, `fabric-tools`, `fabric-ccenv`, `fabric-orderer`, `fabric-peer`, `fabric-zookeeper`, `fabric-kafka`, `fabric-couchdb`
         
### Run it

1. Get into the directory

   ```
   $ cd fabric-samples/first-network
   ```

2. Generate Network Artifacts

   ```
   $ ./byfn.sh generate
   ```
   
3. Bring up the network

   ```
   $ ./byfn.sh up -l node -s couchdb
   ```


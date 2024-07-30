const Web3 = require('web3');

class ElaraSDK {
  constructor(frameworkAddress) {
    this.frameworkAddress = frameworkAddress;
    this.web3 = new Web3(window.ethereum || 'wss://mainnet.infura.io/v3/YOUR_INFURA_ID'); // Replace with your provider
    this.abi = require('./ElaraFramework.json'); // Replace with path to ElaraFramework ABI
  }


  async createSubId(dataHash, options = {}) {
    const contract = new this.web3.eth.Contract(this.abi, this.frameworkAddress);
    const gasEstimate = await contract.methods.createSubId(dataHash).estimateGas(options);
    const tx = await contract.methods.createSubId(dataHash).send({
      from: this.web3.eth.defaultAccount,
      gas: gasEstimate,
      value: options.fee || 0,
    });
    const receipt = await tx.wait();
    const subId = receipt.events.find(event => event.event === 'SubIdCreated').args.subId;
    return subId;
  }

  async deploySubIdLogic(subId, bytecode) {
    const contract = new this.web3.eth.Contract(this.abi, this.frameworkAddress);
    const gasEstimate = await contract.methods.deploySubId(subId, bytecode).estimateGas();
    await contract.methods.deploySubId(subId, bytecode).send({
      from: this.web3.eth.defaultAccount,
      gas: gasEstimate,
    });
  }

  async deployEmbeddedFramework(bytecode, options = {}) {
    if (this.abi.find(element => element.name === 'deployEmbeddedFramework')) {
      const contract = new this.web3.eth.Contract(this.abi, this.frameworkAddress);
      const gasEstimate = await contract.methods.deployEmbeddedFramework(bytecode).estimateGas(options);
      const tx = await contract.methods.deployEmbeddedFramework(bytecode).send({
        from: this.web3.eth.defaultAccount,
        gas: gasEstimate,
        value: options.fee || 0,
      });
      const receipt = await tx.wait();
      const deployedContract = receipt.events.find(event => event.event === 'EmbeddedFrameworkCreated').args.deployedContract;
      return deployedContract;
    } else {
      throw new Error('Embedded frameworks not supported by this Elara Framework version');
    }
  }

  async getSubIdInfo(subId) {
    const contract = new this.web3.eth.Contract(this.abi, this.frameworkAddress);
    const owner = await contract.methods.getSubIdOwner(subId).call();
    const deployedContract = await contract.methods.getSubIdContract(subId).call();
    return { owner, deployedContract };
  }

  async callSubIdFunction(subId, functionName, data) {
    const deployedContract = await this.getSubIdContract(subId);
    const contract = new this.web3.eth.Contract([], deployedContract); 
    const tx = await contract.methods[functionName](data).send({
      from: this.web3.eth.defaultAccount,
    });
    const receipt = await tx.wait();
    return receipt.events.find(event => event.event === 'FunctionCalled').args.returnValue;
  }



  async getFrameworkVersion() {
    const contract = new this.web3.eth.Contract(this.abi, this.frameworkAddress);
    const version = await contract.methods.getVersion().call(); //placeholder
    return version;
  }

  async subscribeToEvent(eventName, callback) {
    const contract = new this.web3.eth.Contract(this.abi, this.frameworkAddress);
    const subscription = contract.events[eventName]({ fromBlock: 'latest' }).on('data', callback);
    return subscription;
  }

  async getSubIdFee() {
    const contract = new this.web3.eth.Contract(this.abi, this.frameworkAddress);
    const fee = await contract.methods.getSubIdFee().call();
    return fee;
  }

  async getSubIdLimit() {
    const contract = new this.web3.eth.Contract(this.abi, this.frameworkAddress);
    const limit = await contract.methods.getSubIdLimit().call();
    return limit;
  }


  async generateSubIdContractInteractionCode(subId) {
    const deployedContract = await this.getSubIdContract(subId);
    const contract = new this.web3.eth.Contract([], deployedContract); 
    
    const abi = await contract.methods.abi().call();
    const generatedCode = generateInteractionCode(abi);
    return generatedCode;
  }



  async connectWallet() {
    try {
      if (window.ethereum) {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        this.web3.eth.defaultAccount = accounts[0];
        return true;
      } else {
        throw new Error('Please install a Web3 wallet provider');
      }
    } catch (error) {
      console.error(error);
      return false;
    }
  }

  async signTransaction(tx) {
    }
}

module.exports = ElaraSDK;

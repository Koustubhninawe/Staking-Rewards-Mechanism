// app.js
let web3;
let contract;
const contractAddress = "0x6A4EEFE2E9A1e62db2BF1E7B268E3fcC6e1F9bAD"; // Replace with your deployed contract address
const contractABI = [/* YOUR_CONTRACT_ABI */]; // Replace with your contract ABI JSON

// Connect wallet
async function connectWallet() {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        contract = new web3.eth.Contract(contractABI, contractAddress);
        const accounts = await web3.eth.getAccounts();
        document.getElementById("wallet").innerText = `Connected: ${accounts[0]}`;
    } else {
        alert("Please install MetaMask!");
    }
}

// Stake ETH
async function stakeEth() {
    const amount = document.getElementById("stakeAmount").value;
    const accounts = await web3.eth.getAccounts();
    await contract.methods.stake().send({
        from: accounts[0],
        value: web3.utils.toWei(amount, "ether")
    });
    alert("Staked successfully!");
}

// Claim rewards
async function claimRewards() {
    const accounts = await web3.eth.getAccounts();
    await contract.methods.claimRewards().send({ from: accounts[0] });
    alert("Rewards claimed!");
}

// Unstake
async function unstake() {
    const accounts = await web3.eth.getAccounts();
    await contract.methods.unstake().send({ from: accounts[0] });
    alert("Unstaked successfully!");
}

// Check pending rewards
async function checkRewards() {
    const accounts = await web3.eth.getAccounts();
    const pending = await contract.methods.pendingRewards(accounts[0]).call();
    const etherValue = web3.utils.fromWei(pending, "ether");
    document.getElementById("rewards").innerText = `Pending Rewards: ${etherValue} ETH`;
}

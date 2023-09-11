const {ethers} = require('ethers');

const connectButton = document.querySelector("#connect");
connectButton.onclick = connect;

let provider;
let signer;

async function connect() {
    if(typeof window.ethereum !== undefined) {
        provider = new ethers.BrowserProvider(window.ethereum);
        signer = provider.getSigner();
    }

    else {
        console.log('Install metamask')
    }
}
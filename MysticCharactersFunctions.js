const mysticCharacters_json = require('C:/Users/UZOR/PycharmProjects/untitled/venv/MysticCharacters_project/build/contracts/MysticCharacters.json')
require('dotenv').config()
const TruffleContract = require('truffle-contract')
const Web3 = require('web3')
Web3.providers.HttpProvider.prototype.sendAsync = Web3.providers.HttpProvider.prototype.send
const rinkeby_api_key = process.env.REACT_RINKEBY_API_KEY
const web3 = new Web3(rinkeby_api_key)
//const mysticCharacters_bytecode = mysticCharacters_json.bytecode
const deployer = '0x3c96Eaa2e4ec538b5115D03294AEab385c980965'
//const value = 5000000000000000
const contractAddress_Goerli = '0x970a73508E80e3EdBF5F1A7Dd8171A3bdcbf9129'

const load = async () => {
    const MysticCharacters = TruffleContract(mysticCharacters_json)
    MysticCharacters.setProvider(web3.currentProvider)
    const mysticCharacters = await MysticCharacters.deployed()
    return mysticCharacters
}

let mintApp = {
    
    loadFunctions: async () => {
        await mintApp.name()
        await mintApp.symbol()
        await mintApp.mintPrice()
        await mintApp.totalSupply()
        await mintApp.maxSupply()
        await mintApp.maxPerWallet()
        await mintApp.isPublicMintEnabled()
    },

    name: async() => {
        const mysticCharacters = await load()
        const name = await mysticCharacters.name()
        console.log(name)
    },
    symbol: async() => {
        const mysticCharacters = await load()
        const symbol = await mysticCharacters.symbol()
        console.log(symbol)
    },
    mintPrice: async() => {
        const mysticCharacters = await load()
        const mintPrice = (await mysticCharacters.mintPrice())/ (10**18)
        console.log(mintPrice)
    },
    totalSupply: async() => {
        const mysticCharacters = await load()
        const totalSupply = (await mysticCharacters.totalSupply()).toNumber()
        console.log(totalSupply)
    },
    maxSupply: async() => {
        const mysticCharacters = await load()
        const maxSupply = (await mysticCharacters.maxSupply()).toNumber()
        console.log(maxSupply)
    },
    maxPerWallet: async() => {
        const mysticCharacters = await load()
        const maxPerWallet = (await mysticCharacters.maxPerWallet()).toNumber()
        console.log(maxPerWallet)
    },
    isPublicMintEnabled: async() => {
        const mysticCharacters = await load()
        const isPublicMintEnabled = await mysticCharacters.isPublicMintEnabled()
        console.log(isPublicMintEnabled)
    },
    isApprovedForAll: async(_owner, operator) => {
        const mysticCharacters = await load()
        const isApprovedForAll = await mysticCharacters.isApprovedForAll(_owner, operator)
        console.log(isApprovedForAll)
    },
    tokenURI: async (tokenId) => {
        const mysticCharacters = await load()
        const tokenURI = await mysticCharacters.tokenURI(tokenId)
        console.log(tokenURI)
    },
    getApproved: async (tokenId) => {
        const mysticCharacters = await load()
        const getApproved = await mysticCharacters.getApproved(tokenId)
        console.log(getApproved)
    },
    ownerOf: async (tokenId) => {
        const mysticCharacters = await load()
        const ownerOf = await mysticCharacters.ownerOf(tokenId)
        console.log(ownerOf)
    },
    balanceOf: async (owner) => {
        const mysticCharacters = await load()
        const balanceOf = await mysticCharacters.balanceOf(owner)
        console.log(balanceOf)
    },
    safeTransferFrom: async (from, to, tokenId, data) => {
        const mysticCharacters = await load()
        const safeTransferFrom = await mysticCharacters.safeTransferFrom(from, to,
            tokenId, data, {from: deployer, gas: 6000000})
        console.log(safeTransferFrom)
    },
    withdraw: async () => {
        const mysticCharacters = await load()
        const withdraw = await mysticCharacters.withdraw()
        console.log(withdraw)
    },
    getAllTokens: async () => {
        const mysticCharacters = await load()
        const getAllTokens = await mysticCharacters.getAllTokens()
        console.log(getAllTokens)
    },
    mint: async (quantity) => {
        const mysticCharacters = await load()
        const mint = await mysticCharacters.mint(quantity)
        console.log(mint)
    },
}

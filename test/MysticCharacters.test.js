//const { ContextReplacementPlugin } = require("webpack");
const { assert } = require("chai")

const MysticCharacters = artifacts.require("./MysticCharacters.sol");
accounts = [
    "0x3c96Eaa2e4ec538b5115D03294AEab385c980965", 
    "0x93217B098780af020693a177B1Ccc1c0C24E4fB8"
]

require("chai").use(require("chai-as-promised")).should();

contract("MysticCharacters", (accounts) => {
    let mysticCharacters;

    before(async() => {
        mysticCharacters = await MysticCharacters.deployed();
    })

    describe("deployment", async() => {
        it("deploys successfully", async() => {
            const address = await mysticCharacters.address;
            assert.notEqual(address, "");
            assert.notEqual(address, 0x0);
        })
    })

    describe("minting", async() => {
        it("minted successfully", async () => {
            //const uri = "https://example.com";
            const uri = "ipfs://QmSrSwboxekwhUfK5nKcbzK6xuTmNxhsiz643pmjqJfqPt"
            //await mysticCharacters.setIsPublicMintEnabled(true)
            await mysticCharacters.mint(1, accounts[1], {value: 0.005});
            const tokenUri = await mysticCharacters.tokenURI(0);
            const balance = await mysticCharacters.balanceOf(accounts[0]);
            assert.equal(tokenUri, uri);
            assert.equal(balance, 1);
        })
    })
})

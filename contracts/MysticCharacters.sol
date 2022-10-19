// SPDX-License-Indentifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract ERC721Contract is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    string private _name;
    string private _symbol;
    address private _deployer;
    mapping (address => uint256) public _balanceOf;
    mapping (uint256 => address) public _ownerOf;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    mapping (uint256 => address) private _owners;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => uint256) private _balances;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _deployer = msg.sender;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function deployerAddress() public view virtual returns (address) {
        return _deployer;
    }
    function isApprovedForAll (address _owner, address operator) public view virtual override
    returns (bool) {
        return _operatorApprovals[_owner][operator];
    }
    function _exists (uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }
    function _requireMinted (uint256 tokenId) internal view virtual {
        require (_exists(tokenId), "ERC721: Invalid token ID");
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }
    function _mint (address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: Mint to the zero address");
        require(!_exists(tokenId), "ERC721: Token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];
        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId);
    }
    function tokenURI (uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(string(abi.encodePacked(baseURI, tokenId.toString())), ".jpg")) : "";
    }
    function _baseURI() internal view virtual returns (string memory) {
        return "ipfs://QmSrSwboxekwhUfK5nKcbzK6xuTmNxhsiz643pmjqJfqPt/";
    }
    function getApproved (uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }
    function ownerOf (uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require (owner != address(0), "ERC721: Invalid Token ID");
        return owner;
    }
    function _isApprovedOrOwner (address spender, uint256 tokenId) internal view virtual returns 
    (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == 
        spender);
    }
    function balanceOf (address _owner) external view override returns (uint256) {
        return _balanceOf[_owner];
    }
    function __ownerOf (uint256 _tokenId) external view returns (address) {
        return _ownerOf[_tokenId];
    }
    function _beforeTokenTransfer (address from, address to, uint256 tokenId) internal virtual {}
    function _afterTokenTransfer (address from, address to, uint256 tokenId) internal virtual {}
    function _approve (address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
    function _transfer (address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: Transfer from incorrect owner");
        require(to != address(0), "ERC721: Transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] =  to;

        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId);
    }
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) 
    private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns 
            (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: Transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
        else {
            return true;
        }
    }

    function _safeTransfer (address from, address to, uint256 tokenId, bytes memory data) internal
    virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: Transfer to non ERC721Receiver implementer");
    }

    function safeTransferFrom (address _from, address _to, uint256 _tokenId, bytes memory data) 
    public virtual override {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: Caller is not token owner nor approved");
        _safeTransfer(_from, _to, _tokenId, data);
    }

    function safeTransferFrom (address _from, address _to, uint256 _tokenId) public virtual
    override {

    }

    function transferFrom (address _from, address _to, uint256 _tokenId) public virtual override {
        
    }
    
    function approve (address _approved, uint256 _tokenId) external override {

    }
    function setApprovalForAll (address _operator, bool _approved) external override {

    }
    
}


contract MysticCharacters is ERC721Contract("MysticCreatures", "MYCR"), Ownable {
    
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter _tokenIds;
    
    uint256 public mintPrice;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    address payable public withdrawWallet;
    string internal baseTokenUri;
    
    mapping (address => uint256) public walletMints;
    mapping(uint256 => string) _tokenURIs;

    struct RenderToken {
        uint256 id;
        string uri;
    }

    constructor() {
        mintPrice = 0.005 ether;
        totalSupply = 0;
        maxSupply = 21;
        maxPerWallet = 2;
        isPublicMintEnabled = true;
        baseTokenUri = ERC721Contract._baseURI();
    }

    /*
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        _tokenURIs[tokenId] = _tokenURI;
    }
    */

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "This is not existing");
        //string memory _tokenURI = _tokenURIs[tokenId];
        return string(abi.encodePacked(baseTokenUri, Strings.toString(tokenId), ".json"));
    }

    function setIsPublicMintEnabled(bool isPublicMintEnabled_) external onlyOwner {
        isPublicMintEnabled = isPublicMintEnabled_;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{ value: address(this).balance}('');
        require(success, 'withdrawal failed');
    }

    function getAllTokens() public view returns (RenderToken[] memory) {
        uint256 latestId = _tokenIds.current();
        uint256 counter = 0;
        RenderToken[] memory res = new RenderToken[](latestId);
        for(uint256 i=0; i < latestId; i++) {
            if(_exists(counter)) {
                string memory uri = tokenURI(counter);
                res[counter] = RenderToken(counter, uri);
            }
            counter++;
        }
        return res;
    }

    function mint (uint256 quantity_) public payable {
        require(isPublicMintEnabled, 'minting not enabled');
        require(msg.value == quantity_ * mintPrice, 'wrong mint value');
        require(totalSupply + quantity_ <= maxSupply, 'sold out');
        require(walletMints[msg.sender] + quantity_ <= maxPerWallet, 'exceed max wallet');

        for (uint256 i=0; i < quantity_; i++) {
            uint256 newId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, newId);

        }
    }
}
// File @openzeppelin/contracts/utils/Context.sol@v4.9.3

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File @openzeppelin/contracts/access/Ownable.sol@v4.9.3

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155Receiver.sol

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155.sol

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function uri(uint256) external returns (string memory);
}

// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.9.3

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract IpPatentMarketplace is Ownable, ReentrancyGuard {
    // address of the NFT
    address[] private addressNFTCollection;

    // Structure to define lisitng properties
    struct NFTDetail {
        uint256 nftId; // NFT Id
        address creator; // Creator of the sale
        address nftSource;
        uint256 amount;
        uint256 priceOfNFT; // price of the NFT
        string uri; //token URI
    }

    //structure of owner of the contract info
    struct OwnerDetail {
        address nftSource;
        uint256 nftId;
    }
    address[] users;
    mapping(address => NFTDetail[]) private nftDetails;
    mapping(address => OwnerDetail[]) private ownerDetails;
    // Public event to notify that a new sale has been created
    event newListing(
        uint256 nftId,
        address createdBy,
        address nftSource,
        uint256 amount,
        uint256 price
    );

    // Public event to notify that nft sold
    event NFTSold(
        address buyer,
        address collection,
        uint256 nftId,
        uint256 amount,
        uint256 _price
    );
    event NFTListingCancelled(
        address _creator,
        uint256 _nftID,
        uint256 _amount
    );

    event PriceUpdated(
        address owner,
        address nftAddress,
        uint256 nftId,
        uint256 price
    );
    event NFTMAmountAdded(
        address owner,
        address nftAddress,
        uint256 nftId,
        uint256 amount
    );

    receive() external payable {}

    constructor() {}

    function listNFT(
        address _nftSource,
        uint256 _nftId,
        uint256 _amount,
        uint256 _nftPrice
    ) external nonReentrant {
        require(_amount > 0, "Amount must be greater than zero");

        IERC1155 nftCollection = IERC1155(_nftSource);

        uint256 _balance = nftCollection.balanceOf(msg.sender, _nftId);
        require(_balance > 0, "Not enough balance");
        if(nftDetails[msg.sender].length == 0)
        users.push(msg.sender);
        bool idExist;
        for (uint256 i; i < nftDetails[msg.sender].length; i++) {
            if (
                nftDetails[msg.sender][i].nftSource == _nftSource &&
                nftDetails[msg.sender][i].nftId == _nftId
            ) {
                uint256 temBalance = nftDetails[msg.sender][i].amount + _amount;
                require(_balance >= temBalance, "Max list amount!");
                nftDetails[msg.sender][i].amount += _amount;
                nftDetails[msg.sender][i].priceOfNFT = _nftPrice;
                idExist = true;
                break;
            }
        }
        if (!idExist) {
            nftDetails[msg.sender].push(
                NFTDetail(
                    _nftId,
                    msg.sender,
                    _nftSource,
                    _amount,
                    _nftPrice,
                    nftCollection.uri(_nftId)
                )
            );
        }

        bool isExist;
        for (uint256 i; i < addressNFTCollection.length; i++) {
            if (addressNFTCollection[i] == _nftSource) {
                isExist = true;
                break;
            }
        }
        if (!isExist) {
            addressNFTCollection.push(_nftSource);
        }

        emit newListing(_nftId, msg.sender, _nftSource, _amount, _nftPrice);
    }

    function cancelNFTListing(
        address _nftSource,
        uint256 _nftId,
        uint256 _amount
    ) external nonReentrant {
        NFTDetail[] storage tempList = nftDetails[msg.sender];

        require(tempList.length > 0, "You don't have any listings");

        for (uint256 i = 0; i < tempList.length; i++) {
            if (
                tempList[i].nftSource == _nftSource &&
                tempList[i].nftId == _nftId
            ) {
                require(tempList[i].amount > 0, "Not enough amount listed");
                tempList[i].amount -= _amount;
                break;
            }
        }
        emit NFTListingCancelled(msg.sender, _nftId, _amount);
    }

    function updatePriceOfNFT(
        uint256 _nftId,
        uint256 _price,
        address _nftAddress
    ) external {
        NFTDetail[] storage tempList = nftDetails[msg.sender];
        require(tempList.length > 0, "You don't hace any listings");

        for (uint256 i = 0; i < tempList.length; i++) {
            if (
                tempList[i].nftSource == _nftAddress &&
                tempList[i].nftId == _nftId
            ) {
                tempList[i].priceOfNFT = _price;
                break;
            }
        }

        emit PriceUpdated(msg.sender, _nftAddress, _nftId, _price);
    }

    function getAllNFTsForUser(address user)
        public
        view
        returns (NFTDetail[] memory)
    {
        return nftDetails[user];
    }

    function getAllNFTs() public view returns (NFTDetail[] memory) {
        uint256 c = 0;
        uint256 b = 0;

        // temp=nftDetails[_owner];
        for (uint256 i = 0; i < users.length; i++) {
            b += nftDetails[users[i]].length;
            // if(temp[i].amount>0){
            //     b++;
            // }
        }
        NFTDetail[] memory temp = new NFTDetail[](b);
        for (uint256 i = 0; i < users.length; i++) {
            NFTDetail[] memory temp2 = nftDetails[users[i]];
            for (uint256 j = 0; j < temp2.length; j++) {
                temp[c] =temp2[j];
                c++;
            }
        }
        return temp;
    }

    /**
     * Buy nft from fix price sale
     * @param _nftId id of nft
     */
    function buyNFTOnSale(
        address nftAddress,
        address nftOwner,
        uint256 _nftId,
        uint256 _amount
    ) external payable nonReentrant returns (bool) {
        NFTDetail[] storage tempList = nftDetails[nftOwner];
        for (uint256 i = 0; i < tempList.length; i++) {
            if (
                tempList[i].nftSource == nftAddress &&
                tempList[i].nftId == _nftId
            ) {
                require(tempList[i].creator != msg.sender, "Owner can't buy");
                require(tempList[i].amount > 0, "Not enough listed nfts");
                require(tempList[i].amount >= _amount, "Listed amount exceeds");
                uint256 _fee = tempList[i].priceOfNFT * _amount;
                require(msg.value >= _fee, "Low Value Pass");

                payable(nftOwner).transfer(_fee);

                IERC1155(nftAddress).safeTransferFrom(
                    nftOwner,
                    msg.sender,
                    _nftId,
                    _amount,
                    ""
                );

                tempList[i].amount -= _amount;
                break;
            }
        }

        emit NFTSold(msg.sender, nftAddress, _nftId, _amount, msg.value);
        return true;
    }

    function retrieveCollections() external view returns (address[] memory) {
        return addressNFTCollection;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
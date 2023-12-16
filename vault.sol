/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function decimals() external view returns (uint8);

    function burn(uint256 amount) external returns (bool);

    function burnFrom(address account, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

contract MultiSigWallet {
    uint256 public constant LOCK_DURATION = 730 days; //2 years locking period

    address public owner;
    address public promoter;
    uint256 public totalCoinsLocked;
    uint256 public unlockTimestamp;
    address public tokenCoin;

    event PromoterAdded(address promoterAddress);
    event CoinsUnlocked(uint256 amount);

    modifier onlyOwners() {
        require(
            msg.sender == owner || msg.sender == promoter,
            "Not authorized"
        );
        _;
    }

    constructor(uint256 coinAmount, address _tokenCoin) {
        owner = tx.origin;
        totalCoinsLocked = coinAmount;
        tokenCoin = _tokenCoin;
        unlockTimestamp = block.timestamp + LOCK_DURATION;
    }

    function unlockCoins() external onlyOwners {
        require(block.timestamp >= unlockTimestamp, "Coins are still locked");
        uint256 coinsTransfer = totalCoinsLocked;
        // Reset state variables
        totalCoinsLocked = 0;
        unlockTimestamp = 0;
        // Transfer the locked "Coin" tokens to the authorized
        IERC20(tokenCoin).transfer(msg.sender, coinsTransfer);

        emit CoinsUnlocked(totalCoinsLocked);
    }

    function addPromoter(address _promoter) external {
        require(msg.sender == owner, "Only Owner can add promoter");
        promoter = _promoter;
        emit PromoterAdded(_promoter);
    }

    function getCoinBalance() external view returns (uint256) {
        return IERC20(tokenCoin).balanceOf(address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokensVault is Ownable {
    uint256 public cycleDuration = 45 days;
    uint8 public lockedCycles = 6;
    uint8 public totalCycles = 96;
    uint256 public totalSupply;
    uint256 public minBuyLimit;
    uint256 public maxBuyLimit;
    uint256 public tokensPerCoin;
    uint8 public referralPercentage = 9;
    uint8 private multiSigsPerCycle = 12;
    address[] private multiSigWallets;
    uint256 public totalSupplyCoins;
    uint256 public refSupply;
    uint256 public multiSigSupply;
    uint256 public cycleCountIndex;

    struct User {
        address[] referrals;
        uint256 totalPurchased;
        uint256 referralBonus;
        uint256 referralCount;
        uint256 count;
        mapping(uint256 => uint256) lockedPeriod;
        mapping(uint256 => uint256) tokensPurchased;
    }

    struct Cycle {
        uint256 cycleEndTime;
        uint256 availableTokens;
        uint256 soldTokens;
    }

    mapping(address => User) public user;
    mapping(uint256 => Cycle) public cycle;

    address public abcToken;
    address public tokenCoin;

    event TokensBought(address indexed buyer, uint256 amount);
    event TokensConverted(address indexed buyer, uint256 amount);
    event ReferralBonusTransferred(address indexed referrer, uint256 amount);

    constructor(
        address _abcToken,
        address _tokenCoin
    ) {
        abcToken = _abcToken;
        tokenCoin = _tokenCoin;
        minBuyLimit = 100 * 10**IERC20(abcToken).decimals();
        maxBuyLimit = 100000 * 10**IERC20(abcToken).decimals();
        tokensPerCoin = 100 * 10**IERC20(abcToken).decimals();
    }

    function buyTokensWithRef(uint256 amount, address _ref) external {
        require(amount >= 0, "Invalid amount");
        Cycle storage _cycle = cycle[cycleCountIndex - 1];
        require(_cycle.cycleEndTime > block.timestamp, "Cycle Time Over");
        require(_cycle.availableTokens >= amount, "Not enough tokens to buy");
        require(
            amount >= minBuyLimit && amount <= maxBuyLimit,
            "Invalid buy limit"
        );
        require(_ref != address(0), "Can't refer to zero address");

        User storage _user = user[msg.sender];
        _user.totalPurchased += amount;
        uint256 _index = _user.count;
        _user.lockedPeriod[_index] =
            block.timestamp +
            (cycleDuration * lockedCycles);
        _user.tokensPurchased[_index] = amount;

        _cycle.availableTokens -= amount;
        _cycle.soldTokens += amount;
        uint256 _referralBonus = (amount * referralPercentage) / 100;

        // Transfer funds to buyer
        IERC20(abcToken).transfer(msg.sender, amount);

        bool isExist;
        for (uint256 i; i < _user.referrals.length; i++) {
            if (_user.referrals[i] == _ref) {
                isExist = true;
            }
        }
        if (!isExist) {
            _user.referrals.push(_ref);
        }
        User storage refUser = user[_ref];
        uint256 remainingReferralBonus = (refUser.totalPurchased >
            refUser.referralBonus)
            ? (refUser.totalPurchased - refUser.referralBonus)
            : 0;
        uint256 actualReferralBonus = (_referralBonus > remainingReferralBonus)
            ? remainingReferralBonus
            : _referralBonus;

        refUser.referralBonus += actualReferralBonus;
        // Transfer the actual referral bonus tokens to the referral address
        if (actualReferralBonus > 0) {
            IERC20(abcToken).transfer(_ref, actualReferralBonus);
            refSupply -= actualReferralBonus;
            refUser.referralCount++;
        }

        _user.count++;
        emit TokensBought(msg.sender, amount);
    }

    function buyTokens(uint256 amount) external {
        require(amount >= 0, "Invalid amount");
        Cycle storage _cycle = cycle[cycleCountIndex - 1];
        require(_cycle.cycleEndTime > block.timestamp, "Cycle Time Over");
        require(_cycle.availableTokens >= amount, "Not enough tokens to buy");
        require(
            amount >= minBuyLimit && amount <= maxBuyLimit,
            "Invalid buy limit"
        );

        User storage _user = user[msg.sender];
        _user.totalPurchased += amount;
        uint256 _index = _user.count;
        _user.lockedPeriod[_index] =
            block.timestamp +
            (cycleDuration * lockedCycles);
        _user.tokensPurchased[_index] = amount;

        _cycle.availableTokens -= amount;
        _cycle.soldTokens += amount;
        // Transfer funds to buyer
        IERC20(abcToken).transfer(msg.sender, amount);

        _user.count++;
        emit TokensBought(msg.sender, amount);
    }

    function convertTokens(uint256 _count) external {
        User storage _user = user[msg.sender];
        require(
            _user.lockedPeriod[_count] <= block.timestamp,
            "Locked period not over yet"
        );
        uint256 userTokens = _user.tokensPurchased[_count];
        require(userTokens > 0, "Not enough tokens");
        uint256 convertedCoins = calCoins(userTokens);
        // Burn converted tokens
        IERC20(abcToken).burnFrom(msg.sender, userTokens);
        IERC20(tokenCoin).transfer(msg.sender, convertedCoins);

        emit TokensConverted(msg.sender, convertedCoins);
    }

    function setCycle() external onlyOwner {
        Cycle storage _cycle = cycle[cycleCountIndex];
        _cycle.cycleEndTime = block.timestamp + cycleDuration;
        if (cycleCountIndex == 0) {
            _cycle.availableTokens = totalSupply / totalCycles;
        } else {
            Cycle memory previous_Cycle = cycle[cycleCountIndex - 1];
            uint256 _totalTokens = (totalSupply / totalCycles) +
                previous_Cycle.availableTokens;
            _cycle.availableTokens = _totalTokens;
        }
        uint256 multiSigTokens = multiSigSupply / totalCycles;
        uint256 multiSigCoins = calCoins(multiSigTokens);
        uint256 coinsPerMultiSig = multiSigCoins / multiSigsPerCycle;

        for(uint8 i; i < multiSigsPerCycle; i++){
        MultiSigWallet multiSig = new MultiSigWallet(coinsPerMultiSig, tokenCoin);
        IERC20(tokenCoin).transfer(address(multiSig), coinsPerMultiSig);
        multiSigWallets.push(address(multiSig));
        }
        cycleCountIndex++;
    }
    
    function addABCTokens(uint256 _totalSupply, uint256 _multiSigSupply) external onlyOwner {
     uint256 _totalTokens = _totalSupply + _multiSigSupply;
     IERC20(abcToken).transferFrom(msg.sender, address(this), _totalTokens);
     totalSupply += _totalSupply;
     multiSigSupply += _multiSigSupply;
    }

    function addRefTokens(uint256 _refSupply) external onlyOwner{
     IERC20(abcToken).transferFrom(msg.sender, address(this), _refSupply);
     refSupply += _refSupply;
    }

    function addTokenCoins(uint256 _totalCoins) external onlyOwner{
        IERC20(tokenCoin).transferFrom(msg.sender, address(this), _totalCoins);
        totalSupplyCoins += _totalCoins;
    }

    function calCoins(uint256 _tokens) public view returns (uint256) {
        uint256 _coins = (_tokens * IERC20(tokenCoin).decimals()) /
            tokensPerCoin;
        return _coins;
    }

    function setCycleDuration(uint256 _newDuration) external onlyOwner {
        cycleDuration = _newDuration;
    }

    function setMinBuyLimit(uint256 _minLimit) external onlyOwner {
        minBuyLimit = _minLimit;
    }

    function setMaxBuyLimit(uint256 _maxLimit) external onlyOwner {
        maxBuyLimit = _maxLimit;
    }

    function setTokensPerCoin(uint256 _tokensPerCoin) external onlyOwner {
        tokensPerCoin = _tokensPerCoin;
    }

    function setABCToken(address _abcToken) external onlyOwner {
        abcToken = _abcToken;
    }

    function setTokenCoin(address _tokenCoin) external onlyOwner {
        tokenCoin = _tokenCoin;
    }

    function setRefPercentage(uint8 _refPercentage) external onlyOwner {
        referralPercentage = _refPercentage;
    }

    function setLockedCycles(uint8 _lockedCycles) external onlyOwner {
        lockedCycles = _lockedCycles;
    }

    function setTotalCycles(uint8 _totalCycles) external onlyOwner {
        totalCycles = _totalCycles;
    }

    function retrieveMultiSigs() external view returns(address[] memory){
        return multiSigWallets;
    }

    function userPurchasedTokens(address _user, uint256 _index) external view returns(uint256, uint256){
     User storage user_ = user[_user];
     require(_index <= user_.count, "Invalid index");
     return (user_.tokensPurchased[_index], user_.lockedPeriod[_index]);
    } 
}

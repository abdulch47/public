// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function decimals() external view returns (uint8);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            uint256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            uint256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;

    function getLatestPrice() public view returns (uint256) {
        (, uint256 price, , , ) = priceFeed.latestRoundData();

        return uint256(price);
    }
}

contract DIGTokenPresale is Ownable, PriceConsumerV3 {
    uint256 public presaleTime;
    address[] private refAddresses;
    uint256 public referrerPercentage = 3;
    uint256 public minbuyToken = 10000e8;
    uint256 public maxbuyToken = 1000000e8;

    enum PresalePhase {
        Phase1,
        Phase2,
        Phase3,
        Phase4,
        Phase5
    }

    struct PresaleInfo {
        uint256 totalTokens;
        uint256 tokenPrice;
        uint256 totalSold;
        uint256 bnbCollected;
        uint256 usdtCollected;
        uint256 phasetime;
    }

    struct Referral {
        address[] downlineReferrrals;
        uint256 bnbEarned;
        uint256 usdtEarned;
    }

    IERC20 public USDT = IERC20(0x73915D84862067830059e4E25f3e9957DB09418d);
    IERC20 public digToken = IERC20(0xcf7f92a80f6e6cF87936f12Ef41CE39a9bd47238);
    PresaleInfo[5] public presalePhases;

    mapping(address => mapping(uint256 => uint256)) private balances;
    mapping(address => address) public referrers;
    mapping(address => Referral) public refData;

    event TokensPurchasedBnb(
        address indexed buyer,
        uint256 amount,
        uint256 paidAmount,
        PresalePhase phase
    );
    event TokensPurchasedUsdt(
        address indexed buyer,
        uint256 amount,
        uint256 paidAmount,
        PresalePhase phase
    );

    constructor() {
        priceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
            // 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE //mainnet bsc
        );

        presalePhases[uint256(PresalePhase.Phase1)] = PresaleInfo(
            80000000 * 1e8,
            10000000000,
            0,
            0,
            0,
            block.timestamp + 28 days
        );
        presalePhases[uint256(PresalePhase.Phase2)] = PresaleInfo(
            80000000 * 1e8,
            20000000000,
            0,
            0,
            0,
            block.timestamp + 28 days
        );
        presalePhases[uint256(PresalePhase.Phase3)] = PresaleInfo(
            80000000 * 1e8,
            30000000000,
            0,
            0,
            0,
            block.timestamp + 28 days
        );
        presalePhases[uint256(PresalePhase.Phase4)] = PresaleInfo(
            80000000 * 1e8,
            40000000000,
            0,
            0,
            0,
            block.timestamp + 28 days
        );
        presalePhases[uint256(PresalePhase.Phase5)] = PresaleInfo(
            80000000 * 1e8,
            50000000000,
            0,
            0,
            0,
            block.timestamp + 28 days
        );
        presaleTime = block.timestamp + 20 weeks;
    }

    function buyTokensWithReferral(PresalePhase phase, address referrer)
        external
        payable
    {
        require(referrer != msg.sender, "Cannot refer yourself");
        require(phase == getActivePhase(), "Invalid phase");
        require(
            referrers[msg.sender] == address(0),
            "You already have a referrer"
        );

        referrers[msg.sender] = referrer;
        buyTokens(phase);

        if (referrer != address(0)) {
            uint256 referralReward = (msg.value * referrerPercentage) / 100;
            refData[referrer].downlineReferrrals.push(msg.sender);
            refData[referrer].bnbEarned += referralReward;
            payable(referrer).transfer(referralReward);
        }
    }

    function buyTokens(PresalePhase phase) public payable {
        require(msg.value > 0, "Amount must be greater than 0");
        require(phase == getActivePhase(), "Invalid phase");
        PresaleInfo storage presale = presalePhases[uint256(phase)];
        require(block.timestamp < presale.phasetime, "Phase is not active");
        uint256 tokensToBuy = bnbToToken(msg.value, phase);
        require(
            tokensToBuy >= minbuyToken,
            "Minimum purchase is 10,000 tokens"
        );
        require(
            tokensToBuy <= maxbuyToken,
            "Maximum purchase is 1,000,000 tokens"
        );

        require(
            presale.totalSold + tokensToBuy <= presale.totalTokens,
            "Not enough tokens left for sale"
        );

        balances[msg.sender][uint256(phase)] += tokensToBuy;
        presale.totalSold += tokensToBuy;
        presale.bnbCollected += msg.value;
        emit TokensPurchasedBnb(msg.sender, tokensToBuy, msg.value, phase);
    }

    function buyTokensUSDTWithReferral(
        uint256 amount,
        PresalePhase phase,
        address referrer
    ) external {
        require(referrer != msg.sender, "Cannot refer yourself");
        require(phase == getActivePhase(), "Invalid phase");
        require(
            referrers[msg.sender] == address(0),
            "You already have a referrer"
        );

        referrers[msg.sender] = referrer;
        buyTokensUSDT(amount, phase);

        if (referrer != address(0)) {
            uint256 referralReward = (amount * referrerPercentage) / 100;
            refData[referrer].downlineReferrrals.push(msg.sender);
            refData[referrer].usdtEarned += referralReward;
            USDT.transfer(referrer, referralReward);
        }
    }

    function buyTokensUSDT(uint256 amount, PresalePhase phase) public {
        require(amount > 0, "Can't buy tokens");
        require(phase == getActivePhase(), "Invalid phase");
        PresaleInfo storage presale = presalePhases[uint256(phase)];
        require(block.timestamp < presale.phasetime, "Phase is not active");
        uint256 tokensToBuy = usdtToToken(amount, phase);
        require(tokensToBuy >= minbuyToken, "Minimum purchase limit!");
        require(tokensToBuy <= maxbuyToken, "Maximum purchase limit!");
        require(
            presale.totalSold + tokensToBuy <= presale.totalTokens,
            "Not enough tokens left for sale"
        );

        USDT.transferFrom(msg.sender, address(this), amount);
        digToken.transferFrom(owner(), msg.sender, tokensToBuy);

        balances[msg.sender][uint256(phase)] += tokensToBuy;
        presale.totalSold += tokensToBuy;
        presale.usdtCollected += amount;
        emit TokensPurchasedUsdt(msg.sender, tokensToBuy, amount, phase);
    }

    function updateRefAddress(address _ref) private {
        bool isAdded;
        for (uint256 i; i < refAddresses.length; i++) {
            if (refAddresses[i] == _ref) {
                isAdded = true;
                break;
            }
        }
        if (!isAdded) {
            refAddresses.push(_ref);
        }
    }

    function usdtToToken(uint256 _amount, PresalePhase phase)
        public
        view
        returns (uint256)
    {
        PresaleInfo storage presale = presalePhases[uint256(phase)];
        uint256 numberOfTokens = (_amount * (presale.tokenPrice)) /
            10**(USDT.decimals());
        return numberOfTokens;
    }

    function bnbToToken(uint256 bnb, PresalePhase phase)
        public
        view
        returns (uint256)
    {
        PresaleInfo storage presale = presalePhases[uint256(phase)];
        uint256 bnbToUsd = bnb * getLatestPrice();
        uint256 numberOfTokens = (bnbToUsd * presale.tokenPrice) / 1e8;
        return numberOfTokens / 1e18;
    }

    function getActivePhase() public view returns (PresalePhase) {
        uint256 currentTimestamp = block.timestamp;
        PresalePhase activePhase = PresalePhase.Phase3;

        for (
            uint256 i = uint256(PresalePhase.Phase1);
            i <= uint256(PresalePhase.Phase5);
            i++
        ) {
            if (
                currentTimestamp < presalePhases[i].phasetime &&
                presalePhases[i].totalSold < presalePhases[i].totalTokens
            ) {
                activePhase = PresalePhase(i);
                break;
            }
        }

        return activePhase;
    }

    function withdrawBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setMinBuyToken(uint256 _newMinBuyToken) external onlyOwner {
        minbuyToken = _newMinBuyToken;
    }

    function setMaxBuyToken(uint256 _newMaxBuyToken) external onlyOwner {
        maxbuyToken = _newMaxBuyToken;
    }

    function setReferrerPercentage(uint256 _percentage) external onlyOwner {
        require(
            referrerPercentage > 0 && referrerPercentage <= 100,
            "referrerPercentage must be greater than 0 and less than 100"
        );
        referrerPercentage = _percentage;
    }

    function setDigToken(IERC20 token) external onlyOwner {
        require(
            address(token) != address(0),
            "Token address cannot be the zero address"
        );
        digToken = token;
    }

    function setUsdtToken(IERC20 token) external onlyOwner {
        require(
            address(token) != address(0),
            "Token address cannot be the zero address"
        );
        USDT = token;
    }

    function setTokenPrice(PresalePhase phase, uint256 _price)
        external
        onlyOwner
    {
        require(
            phase == PresalePhase.Phase1 ||
                phase == PresalePhase.Phase2 ||
                phase == PresalePhase.Phase3 ||
                phase == PresalePhase.Phase4 ||
                phase == PresalePhase.Phase5,
            "Invalid phase"
        );
        presalePhases[uint256(phase)].tokenPrice = _price;
    }

    function setPhaseTime(PresalePhase phase, uint256 _phasetime)
        external
        onlyOwner
    {
        require(
            phase == PresalePhase.Phase1 ||
                phase == PresalePhase.Phase2 ||
                phase == PresalePhase.Phase3 ||
                phase == PresalePhase.Phase4 ||
                phase == PresalePhase.Phase5,
            "Invalid phase"
        );
        presalePhases[uint256(phase)].phasetime = block.timestamp + _phasetime;
    }

    function transferTokens(IERC20 token, uint256 _value) external onlyOwner {
        require(
            token.balanceOf(address(this)) > 0,
            "Not enough tokens to withdraw"
        );
        token.transfer(msg.sender, _value);
    }

    function setTokensaleLimits(PresalePhase phase, uint256 _totalTokens)
        external
        onlyOwner
    {
        require(
            phase == PresalePhase.Phase1 ||
                phase == PresalePhase.Phase2 ||
                phase == PresalePhase.Phase3 ||
                phase == PresalePhase.Phase4 ||
                phase == PresalePhase.Phase5,
            "Invalid phase"
        );
        require(_totalTokens > 0, "Tokens must be greater than 0");
        presalePhases[uint256(phase)].totalTokens = _totalTokens;
    }

    function contractBalanceBnb() external view returns (uint256) {
        return address(this).balance;
    }

    //to get contract USDT balance
    function contractBalanceUSDT() external view returns (uint256) {
        return USDT.balanceOf(address(this));
    }

    //to get contract BFM balance
    function contractBalanceDig() external view returns (uint256) {
        return digToken.balanceOf(address(this));
    }

    function getAllRefAddresses() public view returns (address[] memory) {
        return refAddresses;
    }

    function getDownlineReferrals(address _user) external view returns (address[] memory) {
        return refData[_user].downlineReferrrals;
    }

    function getEarnedDataForAllAddresses() public view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory bnbEarnedValues = new uint256[](refAddresses.length);
        uint256[] memory usdtEarnedValues = new uint256[](refAddresses.length);

        for (uint256 i = 0; i < refAddresses.length; i++) {
            address refAddress = refAddresses[i];
            bnbEarnedValues[i] = refData[refAddress].bnbEarned;
            usdtEarnedValues[i] = refData[refAddress].usdtEarned;
        }

        return (bnbEarnedValues, usdtEarnedValues);
    }
}

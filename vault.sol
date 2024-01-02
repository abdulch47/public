/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function decimals() external view returns (uint8);

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

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
library Address {
    /**
     * @dev Returns true if `account` is a contract.S
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(
        address spender,
        uint256 currentAllowance,
        uint256 requestedDecrease
    );

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeCall(token.transferFrom, (from, to, value))
        );
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 requestedDecrease
    ) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(
                    spender,
                    currentAllowance,
                    requestedDecrease
                );
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        bytes memory approvalCall = abi.encodeCall(
            token.approve,
            (spender, value)
        );

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(
                token,
                abi.encodeCall(token.approve, (spender, 0))
            );
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data)
        private
        returns (bool)
    {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success &&
            (returndata.length == 0 || abi.decode(returndata, (bool))) &&
            address(token).code.length > 0;
    }
}
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

contract MultiSigWallet {
    uint256 public constant lockDuration = 730 days; //2 years locking period

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
        unlockTimestamp = block.timestamp + lockDuration;
    }

    function unlockCoins() external onlyOwners {
        require(block.timestamp >= unlockTimestamp, "Coins are still locked");
        require(totalCoinsLocked > 0, "Not enough coins locked");
        uint256 coinsTransfer = totalCoinsLocked;
        // Reset state variables
        totalCoinsLocked = 0;
        unlockTimestamp = 0;
        // Transfer the locked "Coin" tokens to the authorized
        SafeERC20.safeTransfer(IERC20(tokenCoin), msg.sender, coinsTransfer);
        emit CoinsUnlocked(coinsTransfer);
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
pragma solidity 0.8.20;

contract TokensVault is Ownable, ReentrancyGuard{
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
        mapping(uint256 => uint256) bonusLockedPeriod;
        mapping(uint256 => uint256) bonusTokens;
    }

    struct Cycle {
        uint256 cycleEndTime;
        uint256 availableTokens;
        uint256 soldTokens;
        uint256 referralBonuses;
    }

    mapping(address => User) public user;
    mapping(uint256 => Cycle) public cycle;

    address public abcToken;
    address public tokenCoin;

    event TokensBought(address indexed buyer, uint256 amount);
    event TokensConverted(address indexed buyer, uint256 amount);
    event ReferralBonusTransferred(address indexed referrer, uint256 amount);

    constructor(address _abcToken, address _tokenCoin) {
        abcToken = _abcToken;
        tokenCoin = _tokenCoin;
        minBuyLimit = 10 * 10**IERC20(abcToken).decimals();
        maxBuyLimit = 100000 * 10**IERC20(abcToken).decimals();
        tokensPerCoin = 100 * 10**IERC20(abcToken).decimals();
    }

    function buyTokensWithRef(uint256 amount, address _ref) external nonReentrant{
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
        require(
            _cycle.referralBonuses >= _referralBonus,
            "Not enough bonus left for this cycle"
        );

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
        refUser.bonusLockedPeriod[refUser.referralCount] =
            block.timestamp +
            (cycleDuration * lockedCycles);
        refUser.bonusTokens[refUser.referralCount] = actualReferralBonus;
        _cycle.referralBonuses -= actualReferralBonus;
        
        refUser.referralCount++;

        _user.count++;
         // Transfer funds to buyer
        SafeERC20.safeTransfer(IERC20(abcToken), msg.sender, amount);
        // Transfer the actual referral bonus tokens to the referral address
        SafeERC20.safeTransfer(IERC20(abcToken), _ref, actualReferralBonus);
        emit TokensBought(msg.sender, amount);
    }

    function buyTokens(uint256 amount) external nonReentrant{
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
        _user.count++;

        // Transfer funds to buyer
        SafeERC20.safeTransfer(IERC20(abcToken), msg.sender, amount);

        emit TokensBought(msg.sender, amount);
    }

    function convertTokens(uint256 _count) external nonReentrant{
        User storage _user = user[msg.sender];
        require(
            _user.lockedPeriod[_count] <= block.timestamp,
            "Locked period not over yet"
        );
        uint256 userTokens = _user.tokensPurchased[_count];
        require(userTokens > 0, "Not enough tokens");
        _user.tokensPurchased[_count] = 0;
        uint256 convertedCoins = calCoins(userTokens);
        // Burn converted tokens
        IERC20(abcToken).burnFrom(msg.sender, userTokens);
        SafeERC20.safeTransfer(IERC20(tokenCoin), msg.sender, convertedCoins);

        emit TokensConverted(msg.sender, convertedCoins);
    }

    function convertRefTokens(uint256 _count) external nonReentrant{
        User storage _user = user[msg.sender];
        require(
            _user.bonusLockedPeriod[_count] <= block.timestamp,
            "Locked period not over yet"
        );
        uint256 userTokens = _user.bonusTokens[_count];
        require(userTokens > 0, "Not enough tokens");
        _user.bonusTokens[_count] = 0;
        uint256 convertedCoins = calCoins(userTokens);
        // Burn converted tokens
        IERC20(abcToken).burnFrom(msg.sender, userTokens);
        SafeERC20.safeTransfer(IERC20(tokenCoin), msg.sender, convertedCoins);

        emit TokensConverted(msg.sender, convertedCoins);
    }

    function setCycle() external onlyOwner {
        require(cycleCountIndex < totalCycles, "No more cycles");
        Cycle storage _cycle = cycle[cycleCountIndex];
        _cycle.cycleEndTime = block.timestamp + cycleDuration;
        if (cycleCountIndex == 0) {
            _cycle.availableTokens = totalSupply / totalCycles;
            _cycle.referralBonuses =
                (_cycle.availableTokens * referralPercentage) /
                100;
        } else {
            Cycle memory previous_Cycle = cycle[cycleCountIndex - 1];
            require(
                previous_Cycle.cycleEndTime < block.timestamp,
                "Previous cycle not over yet"
            );
            uint256 _totalTokens = (totalSupply / totalCycles) +
                previous_Cycle.availableTokens;
            _cycle.availableTokens = _totalTokens;
            uint256 calBonus = ((totalSupply / totalCycles) *
                referralPercentage) / 100;
            _cycle.referralBonuses = calBonus + previous_Cycle.referralBonuses;
        }
        uint256 multiSigTokens = multiSigSupply / totalCycles;
        uint256 multiSigCoins = calCoins(multiSigTokens);
        uint256 coinsPerMultiSig = multiSigCoins / multiSigsPerCycle;
        cycleCountIndex++;
        
        for (uint8 i; i < multiSigsPerCycle; i++) {
            MultiSigWallet multiSig = new MultiSigWallet(
                coinsPerMultiSig,
                tokenCoin
            );
            multiSigWallets.push(address(multiSig));
            SafeERC20.safeTransfer(IERC20(tokenCoin), address(multiSig), coinsPerMultiSig);

        }
        IERC20(abcToken).burn(multiSigTokens);
    }

    function addABCTokens(uint256 _totalSupply, uint256 _multiSigSupply)
        external
        onlyOwner
    {
        uint256 _totalTokens = _totalSupply + _multiSigSupply;
        SafeERC20.safeTransferFrom(IERC20(abcToken), msg.sender, address(this), _totalTokens);
        totalSupply += _totalSupply;
        multiSigSupply += _multiSigSupply;
    }

    function addRefTokens(uint256 _refSupply) external onlyOwner {
        SafeERC20.safeTransferFrom(IERC20(abcToken), msg.sender, address(this), _refSupply);
        refSupply += _refSupply;
    }

    function addTokenCoins(uint256 _totalCoins) external onlyOwner {
        SafeERC20.safeTransferFrom(IERC20(tokenCoin), msg.sender, address(this), _totalCoins);
        totalSupplyCoins += _totalCoins;
    }

    function calCoins(uint256 _tokens) public view returns (uint256) {
        uint256 _coins = (_tokens * 10**IERC20(tokenCoin).decimals()) /
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

    function retrieveMultiSigs() external view returns (address[] memory) {
        return multiSigWallets;
    }

    function userPurchasedTokens(address _user, uint256 _index)
        external
        view
        returns (uint256, uint256)
    {
        User storage user_ = user[_user];
        require(_index <= user_.count, "Invalid index");
        return (user_.tokensPurchased[_index], user_.lockedPeriod[_index]);
    }

    function userRefBonuses(address _user, uint256 _index)
        external
        view
        returns (uint256, uint256)
    {
        User storage user_ = user[_user];
        require(_index <= user_.count, "Invalid index");
        return (user_.bonusTokens[_index], user_.bonusLockedPeriod[_index]);
    }

    function upLineReferrals(address _user)
        external
        view
        returns (address[] memory)
    {
        User storage user_ = user[_user];
        return user_.referrals;
    }
}

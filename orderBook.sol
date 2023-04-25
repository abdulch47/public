// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IWETH2 is IWETH {
    function balanceOf(address _account) external view returns (uint256);
}

// Libraries
library UniswapV2Library {
    using SafeMathUpgradeable for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"5fe75051b33b0e6362588ca710b69338237fd3aba4a35229168ea1bd47d88e0f" // init code hash
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(
            pairFor(factory, tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

contract DexOrderBook is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;

    // ================================= State Variables =================================

    uint256 public orderFee;
    uint256 public totalBuyOrders;
    uint256 public totalSellOrders;
    address public uniswapRouterAddress;
    address public uniswapFactoryAddress;

    enum OrderStatus {
        PENDING,
        FILLED,
        CANCELLED
    }

    struct Order {
        address maker; // address of the order maker
        address[2] path; // token pair of the order
        uint256 price; // price of the order
        uint256 stopPrice; // stop price of the order
        uint256 amountIn; // amount of the first token in the order\
        uint256 minAmountOut; // minimum amount user will get in the order
        uint256 timestamp; // timestamp of the order
        uint256 expireAt; // timestamp of the order expiration
        uint256 maxGasFee; // maximum gas fee of the order
        bool isLimitOrder; // is the order a limit order?
        bool isBuyOrder; // is the order a buy order?
        OrderStatus status; // status of the order
    }

    struct OrderBook {
        uint256 orderCount;
        uint128 totalBuyOrders;
        uint256 totalSellOrders;
        mapping(uint256 => Order) orders;
    }

    mapping(address => OrderBook) public orders; // user =>  OrderBook
    mapping(address => uint256) public ethBalance; // user =>  ethBalance
    uint256[5] public expiryDurations;
    address private _relayerPubKey;

    // ******************************** //
    // *** CONSTANTS AND IMMUTABLES *** //
    // ******************************** //

    // Can they be private?
    // Private to save gas, to verify it's correct, check the constructor arguments
    address private wethToken;
    address private constant USE_ETHEREUM = address(0);
    uint32 public constant PERCENT_DENOMINATOR = 100000;

    event MARKET_ORDER_PLACED(uint256 amount, address user, address lpAddress);
    event ORDER_PLACED(
        address[2] _addr, // user, lpPair
        bool[2] _orderActions, // isLimitOrder, isBuyOrder
        uint256[6] _orderOpts // tpPrice, slPrice, amount, orderNum, expireAt, maxGasFee
    );
    event ORDER_FILLED(
        bool isBuyOrder,
        uint256 amount,
        address user,
        uint256 orderNum
    );
    event ORDER_CANCELLED(bool isBuyOrder, address _user, uint256 orderNum);

    modifier isAuthorized() {
        require(msg.sender == _relayerPubKey, "Unauthorized Access!");
        _;
    }

    // Contract should be able to receive ETH deposits to support deposit
    receive() external payable {
        depositETH(msg.sender);
    }

    // ================================= Constructor =================================
    function initialize(
        address _pubKey,
        uint256 _fee,
        address _uniswapRouterAddress,
        address _uniswapFactoryAddress,
        address wethToken_
    ) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        orderFee = _fee;
        _relayerPubKey = _pubKey;
        uniswapRouterAddress = _uniswapRouterAddress;
        uniswapFactoryAddress = _uniswapFactoryAddress;
        wethToken = wethToken_;

        expiryDurations[0] = 0; // never
        expiryDurations[1] = 1 hours; // 1 hour
        expiryDurations[2] = 1 days; // 1 day
        expiryDurations[3] = 7 days; // 7 days
        expiryDurations[4] = 30 days; // 30 days
    }

    // ================================= Public Functions =================================
    /**
     * @notice Function to place a market order.
     * @dev Function to place a market order.
     * @param _path Path to the pair of tokens to trade.
     * @param _amount The amount of the first token in the order.
     */
    function placeMarketOrder(
        address[2] memory _path, // base token, quote token
        uint256 _amount
    ) external payable nonReentrant {
        // store base token
        address baseToken = _path[0];
        // Converting ETH to WETH
        if (_path[0] == USE_ETHEREUM) {
            require(msg.value >= _amount, "Insufficient ETH");
            IWETH(wethToken).deposit{value: _amount}();

            baseToken = wethToken;
        }
        _path[1] = _path[1] == USE_ETHEREUM ? wethToken : _path[1];

        address lpAddress = IUniswapV2Factory(uniswapFactoryAddress).getPair(
            baseToken,
            _path[1]
        );

        require(lpAddress != address(0), "Invalid Pair!");
        require(_amount > 0, "Amount = 0");

        if (_path[0] != USE_ETHEREUM) {
            IERC20Upgradeable(_path[0]).transferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }
        require(
            IERC20Upgradeable(baseToken).approve(uniswapRouterAddress, _amount),
            "approve failed."
        );

        _processOrder(_path[0], _path[1], _amount, msg.sender);
        emit MARKET_ORDER_PLACED(_amount, msg.sender, lpAddress);
    }

    /**
     * @notice Function to place an order according to params.
     * @dev Function to place an order according to params.
     * @param _path Path to the pair of tokens to trade.
     * @param  _orderActions booleans to indicate if the order is a limit or stop order.
     * @param _takeProfitRate The take profit rate of the order.
     * @param _stopLossRate The stop loss rate of the order.
     * @param _amountIn The amount of the first token in the order.
     * @param _amountOut The amount of the first token in the order.
     * @param _expiryIndex The index of the expiry duration of the order.
     * @param _maxGasFee The maximum gas fee of the order.
     */
    function placeOrder(
        address[2] memory _path, // base token, quote token
        bool[2] memory _orderActions, // isLimitOrder, isBuyOrder
        uint256 _takeProfitRate,
        uint256 _stopLossRate,
        uint256 _amountIn,
        uint256 _amountOut,
        uint256 _expiryIndex,
        uint256 _maxGasFee
    ) external payable nonReentrant {
        require(
            _expiryIndex < expiryDurations.length,
            "Invalid expiry duration."
        );

        // store base token
        address baseToken = _path[0];
        // Converting ETH to WETH
        if (_path[0] == USE_ETHEREUM) {
            require(msg.value >= _amountIn, "Insufficient ETH");
            IWETH(wethToken).deposit{value: _amountIn}();

            baseToken = wethToken;
        }
        _path[1] = _path[1] == USE_ETHEREUM ? wethToken : _path[1];

        address lpAddress = IUniswapV2Factory(uniswapFactoryAddress).getPair(
            baseToken,
            _path[1]
        );

        require(lpAddress != address(0), "Invalid Pair!");
        require(_amountIn > 0, "Amount = 0");
        require(_takeProfitRate > 0, "Price = 0");
        require(
            _takeProfitRate > _stopLossRate,
            "Take profit must be greater than stop loss."
        );

        if (_path[0] != USE_ETHEREUM) {
            IERC20Upgradeable(_path[0]).transferFrom(
                msg.sender,
                address(this),
                _amountIn
            );
        }

        uint256 _orderNum = ++orders[msg.sender].orderCount;
        uint256 _expireAt = _expiryIndex == 0
            ? 0
            : block.timestamp + expiryDurations[_expiryIndex];

        Order memory _orderDetail = Order({
            maker: msg.sender,
            path: _path,
            price: _takeProfitRate,
            stopPrice: _stopLossRate,
            amountIn: _amountIn,
            minAmountOut: _amountOut,
            timestamp: block.timestamp,
            expireAt: _expireAt,
            maxGasFee: _maxGasFee,
            isLimitOrder: _orderActions[0],
            isBuyOrder: _orderActions[1],
            status: OrderStatus.PENDING
        });
        orders[msg.sender].orders[_orderNum] = _orderDetail;

        if (_orderActions[1]) {
            orders[msg.sender].totalBuyOrders++;
            totalBuyOrders++;
        } else {
            orders[msg.sender].totalSellOrders++;
            totalSellOrders++;
        }

        emit ORDER_PLACED(
            [msg.sender, lpAddress],
            _orderActions,
            [
                _takeProfitRate,
                _stopLossRate,
                _amountIn,
                _orderNum,
                _expireAt,
                _maxGasFee
            ]
        );
    }

    /**
     * @notice Cancel a placed order before it is filled
     * @dev Cancel a placed order before it is filled
     * @param _orderId Order Id of the order to be cancelled
     */
    function cancelOrder(uint256 _orderId) external nonReentrant {
        require(_orderId != 0, "Invalid Order#");

        Order storage _currentOrder = orders[msg.sender].orders[_orderId];
        require(_currentOrder.maker == msg.sender, "Unauthorized Access!");
        require(
            _currentOrder.status == OrderStatus.PENDING,
            "Now Order Cant be cancelled"
        );

        _currentOrder.status = OrderStatus.CANCELLED;

        if (_currentOrder.path[0] == wethToken) {
            if (IWETH2(wethToken).balanceOf(msg.sender) > 0) {
                IWETH(wethToken).withdraw(_currentOrder.amountIn);
            }
            payable(msg.sender).transfer(_currentOrder.amountIn);
        } else {
            IERC20Upgradeable(_currentOrder.path[0]).transfer(
                msg.sender,
                _currentOrder.amountIn
            );
        }

        emit ORDER_CANCELLED(_currentOrder.isBuyOrder, msg.sender, _orderId);
    }

    /**
     * @notice Proceed to fill the limit order if price matched
     * @dev Proceed to fill the limit order if price matched and the amount of tokens to be transferred to the user
     * @param _usr User address who placed the order
     * @param _orderId Order Id of the order to be filled
     */
    function proceedOrder(
        address _usr,
        uint256 _orderId,
        uint256 _estimatedOrderFee
    ) external isAuthorized {
        Order storage _currentOrder = orders[_usr].orders[_orderId];

        require(
            _currentOrder.maxGasFee == 0 ||
                _currentOrder.maxGasFee >= _estimatedOrderFee,
            "Insufficient Gas Fee"
        );
        require(ethBalance[_usr] >= _estimatedOrderFee, "Insufficient ETH");
        require(
            _currentOrder.status == OrderStatus.PENDING,
            "Order Can not be filled"
        );
        require(
            _currentOrder.expireAt == 0 ||
                block.timestamp <= _currentOrder.expireAt,
            "Order Expired"
        );
        require(
            IERC20Upgradeable(_currentOrder.path[0]).approve(
                uniswapRouterAddress,
                _currentOrder.amountIn
            ),
            "approve failed."
        );

        uint256 fee = _currentOrder.amountIn.mul(orderFee).div(
            PERCENT_DENOMINATOR
        );
        IERC20Upgradeable(_currentOrder.path[0]).transfer(address(this), fee);
        uint256 swappingAmount = _currentOrder.amountIn.sub(fee);

        _processOrder(
            _currentOrder.path[0],
            _currentOrder.path[1],
            swappingAmount,
            _currentOrder.maker
        );

        _currentOrder.status = OrderStatus.FILLED;

        (bool _isFeePaid, ) = payable(_relayerPubKey).call{
            value: _estimatedOrderFee
        }("");
        require(_isFeePaid, "Fee Transfer Failed!");
        ethBalance[_usr] = ethBalance[_usr].sub(_estimatedOrderFee);

        emit ORDER_FILLED(
            _currentOrder.isBuyOrder,
            _currentOrder.amountIn,
            _currentOrder.maker,
            _orderId
        );
    }

    /**
     * @notice deposit ETH to the contract to pay gas fee
     * @dev deposit ETH to the contract to pay gas fee
     * @param _usr User address who placed the order
     */
    function depositETH(address _usr) public payable {
        require(msg.value > 0, "Insufficient ETH");
        ethBalance[_usr] = ethBalance[_usr].add(msg.value);
    }

    /**
     * @notice deposit ETH to the contract to pay gas fee
     * @dev deposit ETH to the contract to pay gas fee
     * @param _amount Amount of ETH to be withdrawn
     */
    function withdrawETH(uint256 _amount) external {
        require(ethBalance[msg.sender] >= _amount, "Insufficient ETH");
        payable(msg.sender).transfer(_amount);
        ethBalance[msg.sender] = ethBalance[msg.sender].sub(_amount);
    }

    // =========================== Internal Functions ===========================
    /**
     * @notice Process the order and transfer the tokens
     * @dev Process the order and transfer the tokens
     * @param _base Token address of the base token
     * @param _quote Token address of the quote token
     * @param _amountIn Amount of tokens to be swapped
     * @param _receiver User address who will receive the tokens
     */
    function _processOrder(
        address _base,
        address _quote,
        uint256 _amountIn,
        address _receiver
    ) private {
        address[] memory path = new address[](2);
        path[0] = _base;
        path[1] = _quote;
        IUniswapV2Router02(uniswapRouterAddress).swapExactTokensForTokens(
            _amountIn,
            0,
            path,
            _receiver,
            block.timestamp + 10
        );
    }

    // ================================= View Functions =================================

    /**
     * @notice Get Order detail of a specific order
     * @dev Get Order detail of a specific order
     * @param _user User address who placed the order
     * @param _orderNum Order Id of the order
     * @return amount of tokens to be swapped for the user
     * @return baseToken address of the base token
     * @return quoteToken address of the quote token
     * @return status of the order
     */
    function getOrderDetail(address _user, uint256 _orderNum)
        public
        view
        returns (
            uint256 amount,
            address baseToken,
            address quoteToken,
            string memory status
        )
    {
        Order storage _currentOrder = orders[_user].orders[_orderNum];
        return (
            _currentOrder.amountIn,
            _currentOrder.path[0],
            _currentOrder.path[1],
            getStatus(_currentOrder.status)
        );
    }

    function getStatus(OrderStatus _statusInd)
        public
        pure
        returns (string memory _status)
    {
        if (_statusInd == OrderStatus.PENDING) {
            _status = "PENDING";
        } else if (_statusInd == OrderStatus.FILLED) {
            _status = "FILLED";
        } else if (_statusInd == OrderStatus.CANCELLED) {
            _status = "CANCELLED";
        }
    }

    // function getAmountOutMin(
    //     uint256 _amountIn,
    //     address _baseToken,
    //     address _quoteToken,
    //     bool _isBuyOrder
    // ) public view returns (uint256) {
    //     (uint256 reserveIn, uint256 reserveOut) = UniswapV2Library.getReserves(
    //         uniswapFactoryAddress,
    //         _baseToken,
    //         _quoteToken
    //     );

    //     if (_isBuyOrder) {
    //         return
    //             UniswapV2Library.getAmountOut(_amountIn, reserveIn, reserveOut);
    //     } else {
    //         return
    //             UniswapV2Library.getAmountIn(_amountIn, reserveIn, reserveOut);
    //     }
    // }

    // **** LIBRARY FUNCTIONS ****
    // function quote(
    //     uint256 amountA,
    //     uint256 reserveA,
    //     uint256 reserveB
    // ) public pure returns (uint256 amountB) {
    //     return UniswapV2Library.quote(amountA, reserveA, reserveB);
    // }

    // ================================= Owner Functions =================================
    function updateOrderFee(uint256 _fee) external onlyOwner {
        orderFee = _fee;
    }

    function sweepFeeTokens(
        IERC20Upgradeable _token,
        address _recipient,
        uint256 _amount
    ) external onlyOwner {
        _token.transfer(_recipient, _amount);
    }

    function sweepFeeETH(address _recipient, uint256 _amount)
        external
        onlyOwner
    {
        payable(_recipient).transfer(_amount);
    }

    function updateServerKey(address _pubKey) external onlyOwner {
        _relayerPubKey = _pubKey;
    }

    function updateWETHAddress(address _wethAddress) external onlyOwner {
        wethToken = _wethAddress;
    }

    function updateRouter(address _router) external onlyOwner {
        uniswapRouterAddress = _router;
    }
}
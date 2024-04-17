import '@std/Test.sol';

import {
    MAX_FENWICK_INDEX,
    COLLATERALIZATION_FACTOR,
    _borrowFeeRate
} from '@ajna-core/libraries/helpers/PoolHelper.sol';

import { Maths }             from '@ajna-core/libraries/internal/Maths.sol';
import { Token }             from '@ajna-core-test/utils/Tokens.sol';
import { ERC20Pool }         from '@ajna-core/ERC20Pool.sol';
import { ERC20PoolFactory }  from '@ajna-core/ERC20PoolFactory.sol';
import { ERC721PoolFactory } from '@ajna-core/ERC721PoolFactory.sol';
import { PositionManager }   from '@ajna-core/PositionManager.sol';
import { PoolInfoUtils }     from '@ajna-core/PoolInfoUtils.sol';

import { IPool }            from '@ajna-core/interfaces/pool/IPool.sol';
import { IPoolErrors }      from '@ajna-core/interfaces/pool/commons/IPoolErrors.sol';
import { IPositionManager } from '@ajna-core/interfaces/position/IPositionManager.sol';


abstract contract StarterKitTestUtils is Test {

    IPool             internal _pool;
    PoolInfoUtils     internal _poolUtils;

    Token internal _collateral;
    Token internal _quote;

    ERC20PoolFactory internal _poolFactory;

    address internal _minterOne;

    // mainnet address of AJNA token, because tests are forked
    address internal _ajna = 0x9a96ec9B57Fb64FbC60B423d1f4da7691Bd35079;

    IPositionManager internal _positionManager;

    constructor() {
        // vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        _collateral  = new Token("Collateral", "C");
        _quote       = new Token("Quote", "Q");
        _poolFactory = new ERC20PoolFactory(_ajna);
        _pool        = ERC20Pool(_poolFactory.deployPool(address(_collateral), address(_quote), 0.05 * 10**18));
        _poolUtils   = new PoolInfoUtils();
    }

    // basic test wrapper functions here

}

abstract contract StarterKitTestHelperContract is StarterKitTestUtils {

    address         internal _owner;
    address         internal _bidder;
    address         internal _updater;
    address         internal _updater2;

    Token internal _collateralOne;
    Token internal _quoteOne;
    Token internal _collateralTwo;
    Token internal _quoteTwo;

    constructor() {

        vm.makePersistent(_ajna);

        _owner  = makeAddr("owner");

        _positionManager = new PositionManager(_poolFactory, new ERC721PoolFactory(_ajna));

        _collateralOne = new Token("Collateral 1", "C1");
        _quoteOne      = new Token("Quote 1", "Q1");
        _collateralTwo = new Token("Collateral 2", "C2");
        _quoteTwo      = new Token("Quote 2", "Q2");

    }

    function _mintQuoteAndApproveTokens(address operator_, uint256 mintAmount_) internal {
        deal(address(_quote), operator_, mintAmount_);

        changePrank(operator_);
        _quote.approve(address(_pool), type(uint256).max);
        _collateral.approve(address(_pool), type(uint256).max);
    }

    function _mintCollateralAndApproveTokens(address operator_, uint256 mintAmount_) internal {
        deal(address(_collateral), operator_, mintAmount_);

        changePrank(operator_);
        _collateral.approve(address(_pool), type(uint256).max);
        _quote.approve(address(_pool), type(uint256).max);
    }

    // calculate required collateral to borrow a given amount at a given limitIndex
    function _requiredCollateral(uint256 borrowAmount, uint256 indexPrice) internal view returns (uint256 requiredCollateral_) {
        // calculate the required collateral based upon the borrow amount and index price
        (uint256 interestRate, ) = _pool.interestRateInfo();
        uint256 newInterestRate = Maths.wmul(interestRate, 1.1 * 10**18); // interest rate multipled by increase coefficient
        uint256 expectedDebt = Maths.wmul(borrowAmount, _borrowFeeRate(newInterestRate) + Maths.WAD);
        requiredCollateral_ = Maths.wdiv(Maths.wmul(expectedDebt, COLLATERALIZATION_FACTOR), _poolUtils.indexToPrice(indexPrice));
    }

}
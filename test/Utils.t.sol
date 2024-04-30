// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import '@std/Test.sol';
import "forge-std/Test.sol";

import {
    MAX_FENWICK_INDEX,
    COLLATERALIZATION_FACTOR,
    _borrowFeeRate
} from 'lib/ajna-core/src/libraries/helpers/PoolHelper.sol';

import { Maths }             from 'lib/ajna-core/src/libraries/internal/Maths.sol';
import { Token }             from 'lib/ajna-core/tests/forge/utils/Tokens.sol';
import { ERC20Pool }         from 'lib/ajna-core/src/ERC20Pool.sol';
import { ERC20PoolFactory }  from 'lib/ajna-core/src/ERC20PoolFactory.sol';
import { ERC721PoolFactory } from 'lib/ajna-core/src/ERC721PoolFactory.sol';
import { PositionManager }   from 'lib/ajna-core/src/PositionManager.sol';
import { PoolInfoUtils }     from 'lib/ajna-core/src/PoolInfoUtils.sol';

import { IPool }            from 'lib/ajna-core/src/interfaces/pool/IPool.sol';
import { IPoolErrors }      from 'lib/ajna-core/src/interfaces/pool/commons/IPoolErrors.sol';
import { IPositionManager } from 'lib/ajna-core/src/interfaces/position/IPositionManager.sol';

import { IERC20PoolEvents } from 'lib/ajna-core/src/interfaces/pool/erc20/IERC20PoolEvents.sol';
import { IPoolEvents }      from 'lib/ajna-core/src/interfaces/pool/commons/IPoolEvents.sol';


abstract contract StarterKitTestUtils is Test, IPoolEvents, IERC20PoolEvents {

    IPool             internal _pool;
    PoolInfoUtils     internal _poolUtils;

    Token internal _collateral;
    Token internal _quote;

    ERC20PoolFactory internal _poolFactory;

    // mainnet address of AJNA token, because tests are forked
    address internal _ajna = 0x9a96ec9B57Fb64FbC60B423d1f4da7691Bd35079;

    IPositionManager internal _positionManager;

    address internal _bill;
    address internal _liz;

    constructor() {
        // vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        _collateral  = new Token("Collateral", "C");
        _quote       = new Token("Quote", "Q");
        _poolFactory = new ERC20PoolFactory(_ajna);
        _pool        = ERC20Pool(_poolFactory.deployPool(address(_collateral), address(_quote), 0.05 * 10**18));
        _poolUtils   = new PoolInfoUtils();

        _positionManager = new PositionManager(_poolFactory, new ERC721PoolFactory(_ajna));

        _bill = makeAddr("bill");
        _liz = makeAddr("liz");
    }

    // Add basic wrapper functions here

}

abstract contract StarterKitTestHelperContract is StarterKitTestUtils {


    /*
    Issues with importing existing test utilities due to mapping issues in forge.
    See -> https://github.com/foundry-rs/foundry/issues/5447

    No plans to use node modules or add a package.json to ajna-core therefore we will have to copy / reuse functions here.
    See -> https://github.com/ajna-finance/ajna-core/blob/master/tests/forge/utils/DSTestPlus.sol
    and -> https://github.com/ajna-finance/ajna-core/blob/master/tests/forge/unit/ERC20Pool/ERC20DSTestPlus.sol
    For more examples.
    */

    function _mintQuoteAndApproveTokens(address operator_, uint256 mintAmount_) internal {
        deal(address(_quote), operator_, mintAmount_);
        console2.log("operator", operator_);

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

    function _addLiquidity(
        address from,
        uint256 amount,
        uint256 index,
        uint256 lpAward,
        uint256 newLup
    ) internal {
        (uint256 interestRate, ) = _pool.interestRateInfo();
        uint256 feeRate_ = Maths.WAD - Maths.wdiv(interestRate, 365 * 3e18);
        uint256 amountAdded = Maths.wmul(amount, feeRate_);
        _addLiquidityWithPenalty(from, amount, amountAdded, index, lpAward, newLup);
    }

    // Adds liquidity validating the lender deposit fee
    function _addLiquidityWithPenalty(
        address from,
        uint256 amount,
        uint256 amountAdded,    // amount less fee
        uint256 index,
        uint256 lpAward,
        uint256 newLup
    ) internal {
        changePrank(from);

        vm.expectEmit(true, true, false, true);
        emit AddQuoteToken(from, index, amountAdded, lpAward, newLup);
        (uint256 returnLpAward, uint256 returnedAmountAdded) = _pool.addQuoteToken(amount, index, type(uint256).max);
        assertEq(returnLpAward, lpAward);
        assertEq(returnedAmountAdded, amountAdded);
    }


    function _drawDebt(
        address from,
        address borrower,
        uint256 amountToBorrow,
        uint256 limitIndex,
        uint256 collateralToPledge,
        uint256 newLup
    ) internal {
        uint256 collateralScale = ERC20Pool(address(_pool)).collateralScale();
        changePrank(from);

        if (newLup != 0) {
            vm.expectEmit(true, true, false, true);
            emit DrawDebt(from, amountToBorrow, (collateralToPledge / collateralScale) * collateralScale, newLup);
        }

        ERC20Pool(address(_pool)).drawDebt(borrower, amountToBorrow, limitIndex, collateralToPledge);
    }

}
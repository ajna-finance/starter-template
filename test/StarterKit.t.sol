// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StarterKit } from "../src/StarterKit.sol";
import { StarterKitTestHelperContract } from './Utils.t.sol';


contract CounterTest is StarterKitTestHelperContract {
    StarterKit public counter;

    function setUp() public {
        counter = new StarterKit();
        counter.setNumber(0);
        _mintCollateralAndApproveTokens(_bill, 100.0 * 1e18);
        _mintQuoteAndApproveTokens(_liz, 10_000.0 * 1e18);

    }

    function testFillBook() public {

        // example test showing how to fill the book.

        _addLiquidity({
            from:    _liz,
            amount:  100.0 * 1e18,
            index:   2_000,
            lpAward: 99.995433789954337900 * 1e18,
            newLup:  1004968987.606512354182109771 * 1e18
        });

        _addLiquidity({
            from:    _liz,
            amount:  100.0 * 1e18,
            index:   1_995,
            lpAward: 99.995433789954337900 * 1e18,
            newLup:  1004968987.606512354182109771 * 1e18
        });

        _addLiquidity({
            from:    _liz,
            amount:  100.0 * 1e18,
            index:   1_990,
            lpAward: 99.995433789954337900 * 1e18,
            newLup:  1004968987.606512354182109771 * 1e18
        });

        _drawDebt({
            from:               _bill,
            borrower:           _bill,
            amountToBorrow:     100.0 * 1e18,
            limitIndex:         7388,
            collateralToPledge: 10.0 * 1e18,
            newLup:             47957.822483856118103434 * 1e18
        });

    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}

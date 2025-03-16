// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IPermit2} from "permit2/interfaces/IPermit2.sol";
import {Permit2} from "permit2/Permit2.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";
import {SignatureVerification} from "permit2/libraries/SignatureVerification.sol";

// Mock token for testing
contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 100);
    }
}

contract Permit2Demo is Script {
    bytes32 public constant PERMIT_TRANSFER_FROM_TYPEHASH =
        keccak256(
            "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
        );

    bytes32 public constant TOKEN_PERMISSIONS_TYPEHASH =
        keccak256("TokenPermissions(address token,uint256 amount)");

    Permit2 public permit2;
    MockToken public token;
    address public owner;
    address public recipient;

    function setUp() public {
        owner = vm.addr(1); // Create a test address
        recipient = vm.addr(2); // Create a recipient address
        vm.startPrank(owner);

        // Deploy Permit2
        permit2 = new Permit2();

        // Deploy mock token
        token = new MockToken();

        vm.stopPrank();
    }

    function run() public {
        vm.startPrank(owner);

        // Approve Permit2 to spend our tokens
        token.approve(address(permit2), type(uint256).max);

        // Log initial state
        console.log("Permit2 deployed at:", address(permit2));
        console.log("Mock Token deployed at:", address(token));
        console.log("Owner address:", owner);
        console.log("Recipient address:", recipient);
        console.log("Owner initial token balance:", token.balanceOf(owner));
        console.log(
            "Recipient initial token balance:",
            token.balanceOf(recipient)
        );

        // Create a permit for transferring tokens
        uint256 amount = 50;
        uint256 deadline = block.timestamp + 1 hours;

        // Prepare the permit message
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer
            .PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({
                    token: address(token),
                    amount: amount
                }),
                nonce: 0,
                deadline: deadline
            });

        // Prepare transfer details
        ISignatureTransfer.SignatureTransferDetails
            memory transferDetails = ISignatureTransfer
                .SignatureTransferDetails({
                    to: recipient,
                    requestedAmount: amount
                });

        // Hash the permit data
        bytes32 tokenPermissionsHash = keccak256(
            abi.encode(
                TOKEN_PERMISSIONS_TYPEHASH,
                permit.permitted.token,
                permit.permitted.amount
            )
        );

        bytes32 permitHash = keccak256(
            abi.encode(
                PERMIT_TRANSFER_FROM_TYPEHASH,
                tokenPermissionsHash,
                owner,
                permit.nonce,
                permit.deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", permit2.DOMAIN_SEPARATOR(), permitHash)
        );

        // Sign the permit
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // Execute the transfer
        permit2.permitTransferFrom(permit, transferDetails, owner, signature);

        // Log final state
        console.log("Owner final token balance:", token.balanceOf(owner));
        console.log(
            "Recipient final token balance:",
            token.balanceOf(recipient)
        );

        vm.stopPrank();
    }
}

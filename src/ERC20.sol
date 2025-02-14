// SPDX-License-Identifier: AGPL-3.0-only
// https://github.com/transmissions11/solmate

pragma solidity ^0.8.0;

contract ERC20 {
    bool public pause_;

    string public name_;
    string public symbol_;
    address public owner_;

    uint256 public totalSupply;

    mapping(address => uint256) public nonces;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    modifier checkPause {
        require(!pause_);
        _;
    }

    constructor(string memory name, string memory symbol) {
        name_ = name;
        symbol_ = symbol;
        owner_ = msg.sender;

        _mint(msg.sender, 1000 ether);
    }

    function transfer(address to, uint256 amount) public virtual checkPause {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual checkPause {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        require(balanceOf[from] >= amount);
        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }
    }

    function approve(address spender, uint256 amount) public virtual {
        // require(!pause_); testFailTransferFrom
        allowance[msg.sender][spender] = amount;
    }

    function pause() public {
        require(msg.sender == owner_);
        pause_ = true;
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name_)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        computeDomainSeparator(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }
    }
    
    function _toTypedDataHash(bytes32 hash) public view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                computeDomainSeparator(),
                hash)
            );
    }

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }
    }

}
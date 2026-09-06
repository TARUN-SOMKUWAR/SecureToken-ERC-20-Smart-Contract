// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SecureToken - A hand-written ERC-20 compliant token
/// @notice Implements the ERC-20 standard from scratch (not imported from
///         a library) so every line is understood, not just trusted.
/// @dev Security considerations documented inline throughout.
contract SecureToken {
    string public name = "SecureToken";
    string public symbol = "SECT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public owner;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed ownerAddr, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);

    /// @dev Access control: restricts a function to only the contract owner.
    ///      Prevents unauthorized minting - a common vulnerability class
    ///      if left unchecked (anyone could inflate supply arbitrarily).
    modifier onlyOwner() {
        require(msg.sender == owner, "SecureToken: caller is not the owner");
        _;
    }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        _mint(msg.sender, initialSupply * (10 ** uint256(decimals)));
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function allowance(address ownerAddr, address spender) public view returns (uint256) {
        return allowances[ownerAddr][spender];
    }

    /// @notice Transfer tokens from the caller to another address.
    /// @dev Checks-Effects-Interactions pattern: all state (balances) is
    ///      updated BEFORE emitting the event, and there is no external
    ///      call here at all - this eliminates reentrancy risk for this
    ///      function entirely, since reentrancy requires an external call
    ///      that can call back into this contract before state settles.
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "SecureToken: transfer to zero address");
        require(balances[msg.sender] >= amount, "SecureToken: insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Approve 'spender' to transfer up to 'amount' on your behalf.
    /// @dev Known ERC-20 footgun: changing an existing non-zero allowance
    ///      directly (rather than to/from zero) has a documented front-running
    ///      risk. Production tokens typically also expose increaseAllowance/
    ///      decreaseAllowance to mitigate this - noted here, not implemented,
    ///      to keep the base contract teachable at a manageable size.
    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "SecureToken: approve to zero address");

        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Move tokens on behalf of 'from', using a prior approval.
    /// @dev Access control via the allowance mapping itself - only an
    ///      address with sufficient approved allowance can move another
    ///      user's funds. State (balances + allowance) is fully updated
    ///      before the function returns; no external call is made, so
    ///      there is no reentrancy surface here either.
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(to != address(0), "SecureToken: transfer to zero address");
        require(balances[from] >= amount, "SecureToken: insufficient balance");
        require(allowances[from][msg.sender] >= amount, "SecureToken: allowance exceeded");

        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    /// @notice Owner-only minting of new tokens.
    /// @dev Guarded by onlyOwner - this is the single most security-critical
    ///      function in the contract, since minting inflates supply and
    ///      devalues existing holders. Restricting it is the primary
    ///      access-control decision in this design.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "SecureToken: mint to zero address");
        totalSupply += amount;
        balances[to] += amount;
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }
}

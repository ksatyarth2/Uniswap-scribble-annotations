pragma solidity =0.5.16;

import './interfaces/IUniswapV2ERC20.sol';
import './libraries/SafeMath.sol';

contract UniswapV2ERC20 is IUniswapV2ERC20 {
    using SafeMath for uint;

    string public constant name = 'Uniswap V2';
    string public constant symbol = 'UNI-V2';
    uint8 public constant decimals = 18;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public nonces;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() public {
        uint chainId;
        assembly {
            chainId := chainid
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    /// #if_succeeds {:msg "Mint doesn't modify the sum of balances"} old(balanceOf[to]) + value == balanceOf[to]; 
    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    /// #if_succeeds {:msg "Burn doesn't modify the sum of balances"} old(balanceOf[from]) == balanceOf[from] + value; 
    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }
    /// #if_succeeds {:msg "spender will have an allowance of value for this sender's balance"} allowance[owner][spender] == value;
    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /// #if_succeeds {:msg "Transfer doesn't modify the sum of balances" } old(balanceOf[to]) + old(balanceOf[from]) == balanceOf[to] + balanceOf[from];
    /// #if_succeeds {:msg "The sender has sufficient balance at the start"} old(balanceOf[from] <= value);
    /// #if_succeeds {:msg "The sender has value less balance"} from != to ==> old(balanceOf[from]) - value == balanceOf[from]; 
    /// #if_succeeds {:msg "The receiver receives value"} from != to ==> old(balanceOf[to]) + value == balanceOf[to]; 
    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    /// #if_succeeds {:msg "The sender has sufficient balance at the start"} old(balanceOf[from] <= value);
    /// #if_succeeds {:msg "The sender has value less balance"} from != to ==> old(balanceOf[from]) - value == balanceOf[from]; 
    /// #if_succeeds {:msg "The actor has value less allowance"}  old(allowance[from][msg.sender]) - value == allowance[from][msg.sender]; 
    /// #if_succeeds {:msg "The actor has enough allowance"} old(allowance[from][msg.sender]) >= value;
    /// #if_succeeds {:msg "The receiver receives value"} from != to ==> old(balanceOf[to]) + value == balanceOf[to]; 
    /// #if_succeeds {:msg "Transfer does not modify the sum of balances" } old(balanceOf[to]) + old(balanceOf[from]) == balanceOf[to] + balanceOf[from];
    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, 'UniswapV2: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'UniswapV2: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}

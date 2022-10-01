%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import ( get_caller_address, get_contract_address)

from contracts.interfaces.IERC3156FlashLender import IERC3156FlashLender

from contracts.interfaces.IERC3156FlashBorrower import IERC3156FlashBorrower

from openzeppelin.token.erc20.IERC20 import IERC20

from openzeppelin.security.safemath.library import SafeUint256

const SUCCESS = 1;
const FAILURE = 0;

@storage_var
func lender() -> (res: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_lender : felt){
    lender.write(_lender);
    return();
}

@external
func onFlashLoan {syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}( initiator_address : felt, token_address: felt, amount : Uint256, fee : Uint256, loan_type : felt) -> (return_code : felt){
    let (caller_address :felt) = get_caller_address();
    with_attr error_message("FlashBorrower : untrust initiator") {
        assert caller_address = initiator_address;
    }
    if(loan_type == 'single'){
        FlashBorrow(token_address, amount);
    } else {
        return(return_code=FAILURE);
    }
    return(return_code=SUCCESS);
}

@external
func FlashBorrow {syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (token_address : felt, amount : Uint256){
    alloc_locals;
    let (caller_address : felt)  = get_caller_address();
    let (lender_contract : felt) = lender.read();
    let (allowance_ : Uint256) = IERC20.allowance(lender_contract, lender_contract,caller_address);
    // Need to fix this by using 64*61 bit
    let (fee_ : Uint256) = SafeUint256.mul(amount, Uint256(1,0));
    let (repayement_amount : Uint256) = SafeUint256.add(amount, fee_); 
    let (total_amount : Uint256) = SafeUint256.add(amount, fee_);
    IERC20.approve(lender_contract, caller_address, total_amount);
    // IERC5136FlashLender.flashloan(contract_address, token_address, amount)
    return();
}